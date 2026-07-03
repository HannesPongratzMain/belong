import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'firebase_auth_client.dart';
import 'firebase_config.dart';

/// Vom Server abgelehnter Zugriff (Rules) — z. B. Chat ohne Teilnahme.
class RtdbPermissionDeniedException implements Exception {
  const RtdbPermissionDeniedException(this.path);

  final String path;
}

/// Schlanker REST-Client für die Realtime Database.
///
/// Kann alles, was die Repositories brauchen: CRUD, Push-IDs, bedingte
/// Schreibzugriffe über ETags (Ersatz für Transaktionen) und Live-Updates
/// über das Server-Sent-Events-Streaming der RTDB.
class RtdbClient {
  RtdbClient(this._auth, {http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final FirebaseAuthClient _auth;
  final http.Client _http;

  Future<Uri> _uri(String path, [Map<String, String>? params]) async {
    final token = await _auth.idToken();
    return Uri.parse('${BelongFirebaseConfig.databaseUrl}/$path.json').replace(
      queryParameters: {'auth': token, ...?params},
    );
  }

  dynamic _decodeOrThrow(http.Response response, String path) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw RtdbPermissionDeniedException(path);
    }
    if (response.statusCode >= 400) {
      throw Exception('RTDB $path: ${response.statusCode} ${response.body}');
    }
    return jsonDecode(response.body);
  }

  Future<dynamic> get(String path) async =>
      _decodeOrThrow(await _http.get(await _uri(path)), path);

  Future<void> put(String path, Object? value) async =>
      _decodeOrThrow(
          await _http.put(await _uri(path), body: jsonEncode(value)), path);

  /// Multi-Location-Update (mehrere Pfade atomar relativ zu [path]).
  Future<void> patch(String path, Map<String, Object?> value) async =>
      _decodeOrThrow(
          await _http.patch(await _uri(path), body: jsonEncode(value)), path);

  Future<void> delete(String path) async =>
      _decodeOrThrow(await _http.delete(await _uri(path)), path);

  /// Push: legt einen Kindknoten mit generierter ID an, gibt die ID zurück.
  Future<String> push(String path, Object? value) async {
    final json = _decodeOrThrow(
        await _http.post(await _uri(path), body: jsonEncode(value)), path);
    return (json as Map<String, dynamic>)['name'] as String;
  }

  /// Bedingtes Update über ETag — der REST-Ersatz für Transaktionen.
  /// [transform] bekommt den aktuellen Wert und liefert den neuen;
  /// bei zwischenzeitlicher Änderung (HTTP 412) wird neu versucht.
  Future<void> compareAndSet(
    String path,
    Object? Function(dynamic current) transform, {
    int maxRetries = 4,
  }) async {
    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      final getResponse = await _http.get(
        await _uri(path),
        headers: {'X-Firebase-ETag': 'true'},
      );
      final current = _decodeOrThrow(getResponse, path);
      final etag = getResponse.headers['etag'] ?? '';

      final putResponse = await _http.put(
        await _uri(path),
        headers: {'if-match': etag},
        body: jsonEncode(transform(current)),
      );
      if (putResponse.statusCode == 412) continue; // Konflikt → neu lesen
      _decodeOrThrow(putResponse, path);
      return;
    }
    throw Exception('RTDB $path: zu viele gleichzeitige Änderungen');
  }

  /// Live-Sicht auf einen Knoten: emittiert nach jeder Änderung den
  /// kompletten (lokal nachgeführten) JSON-Wert des Pfads.
  Stream<dynamic> watch(String path) {
    late StreamController<dynamic> controller;
    StreamSubscription<String>? lines;
    http.Client? streamClient;
    var cancelled = false;
    dynamic tree;

    Future<void> connect() async {
      while (!cancelled) {
        try {
          final client = http.Client();
          streamClient = client;
          final request = http.Request('GET', await _uri(path))
            ..headers['Accept'] = 'text/event-stream';
          final response = await client.send(request);
          if (response.statusCode == 401 || response.statusCode == 403) {
            controller.addError(RtdbPermissionDeniedException(path));
            return;
          }
          if (response.statusCode >= 400) {
            throw http.ClientException('HTTP ${response.statusCode}', request.url);
          }

          String? event;
          final done = Completer<void>();
          lines = response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .listen((line) {
            if (line.startsWith('event:')) {
              event = line.substring(6).trim();
            } else if (line.startsWith('data:')) {
              final data = line.substring(5).trim();
              switch (event) {
                case 'put' || 'patch':
                  final body = jsonDecode(data) as Map<String, dynamic>;
                  tree = _apply(tree, body['path'] as String, body['data'],
                      merge: event == 'patch');
                  controller.add(tree);
                case 'cancel':
                  // Rules haben den Stream beendet (z. B. Rechte entzogen).
                  controller.addError(RtdbPermissionDeniedException(path));
                case 'auth_revoked':
                  // Token abgelaufen → Verbindung mit frischem Token neu aufbauen.
                  done.complete();
              }
            }
          }, onDone: () {
            if (!done.isCompleted) done.complete();
          }, onError: (Object _) {
            if (!done.isCompleted) done.complete();
          });
          await done.future;
          await lines?.cancel();
          client.close();
        } on Exception {
          if (cancelled) return;
          // Verbindungsfehler: kurz warten, dann neu verbinden.
          await Future<void>.delayed(const Duration(seconds: 2));
        }
      }
    }

    controller = StreamController<dynamic>(
      onListen: connect,
      onCancel: () async {
        cancelled = true;
        await lines?.cancel();
        streamClient?.close();
      },
    );
    return controller.stream;
  }

  /// Wendet ein put/patch-Ereignis relativ zum beobachteten Knoten an.
  static dynamic _apply(dynamic tree, String path, dynamic data,
      {required bool merge}) {
    final segments =
        path.split('/').where((segment) => segment.isNotEmpty).toList();
    if (segments.isEmpty) {
      if (!merge) return data;
      final map = (tree is Map ? Map<String, dynamic>.from(tree) : <String, dynamic>{});
      (data as Map<String, dynamic>).forEach((key, value) {
        value == null ? map.remove(key) : map[key] = value;
      });
      return map;
    }

    final root = (tree is Map ? Map<String, dynamic>.from(tree) : <String, dynamic>{});
    Map<String, dynamic> node = root;
    for (final segment in segments.sublist(0, segments.length - 1)) {
      final child = node[segment];
      final next = (child is Map ? Map<String, dynamic>.from(child) : <String, dynamic>{});
      node[segment] = next;
      node = next;
    }
    final leaf = segments.last;
    if (merge) {
      final child = node[leaf];
      final target =
          (child is Map ? Map<String, dynamic>.from(child) : <String, dynamic>{});
      (data as Map<String, dynamic>).forEach((key, value) {
        value == null ? target.remove(key) : target[key] = value;
      });
      node[leaf] = target;
    } else if (data == null) {
      node.remove(leaf);
    } else {
      node[leaf] = data;
    }
    return root;
  }
}
