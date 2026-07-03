import 'dart:convert';

import 'package:http/http.dart' as http;

import 'credential_store_io.dart'
    if (dart.library.js_interop) 'credential_store_web.dart';
import 'firebase_config.dart';

/// Anonyme Firebase-Authentifizierung über die Identity-Toolkit-REST-API.
///
/// Passend zur Produktidee gibt es keinerlei Login-Daten: beim ersten Start
/// wird ein anonymes Konto erzeugt; uid + Refresh-Token werden lokal
/// gespeichert, damit die Identität (Profil, Teilnahmen) erhalten bleibt.
class FirebaseAuthClient {
  FirebaseAuthClient({http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final http.Client _http;

  String? _uid;
  String? _idToken;
  String? _refreshToken;
  DateTime _tokenExpiry = DateTime.fromMillisecondsSinceEpoch(0);

  String get uid {
    final value = _uid;
    if (value == null) {
      throw StateError('ensureSignedIn() muss vor dem uid-Zugriff laufen.');
    }
    return value;
  }

  /// Gültiges ID-Token liefern; meldet bei Bedarf an oder erneuert es.
  Future<String> idToken() async {
    await ensureSignedIn();
    if (DateTime.now().isBefore(_tokenExpiry)) return _idToken!;
    await _refresh();
    return _idToken!;
  }

  Future<void> ensureSignedIn() async {
    if (_uid != null) return;

    // Gespeicherte Sitzung wiederverwenden …
    final stored = await loadCredentials();
    if (stored != null) {
      try {
        final json = jsonDecode(stored) as Map<String, dynamic>;
        _uid = json['uid'] as String?;
        _refreshToken = json['refreshToken'] as String?;
        if (_uid != null && _refreshToken != null) {
          await _refresh();
          return;
        }
      } on Exception {
        // Kaputte/abgelaufene Sitzung → neu anmelden.
        _uid = null;
        _refreshToken = null;
      }
    }

    // … sonst neues anonymes Konto anlegen.
    final response = await _http.post(
      Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp'
          '?key=${BelongFirebaseConfig.apiKey}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'returnSecureToken': true}),
    );
    final json = _decodeOrThrow(response, 'Anonyme Anmeldung fehlgeschlagen');
    _uid = json['localId'] as String;
    _idToken = json['idToken'] as String;
    _refreshToken = json['refreshToken'] as String;
    _setExpiry(json['expiresIn'] as String?);
    await _persist();
  }

  Future<void> _refresh() async {
    final response = await _http.post(
      Uri.parse('https://securetoken.googleapis.com/v1/token'
          '?key=${BelongFirebaseConfig.apiKey}'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'grant_type=refresh_token&refresh_token=$_refreshToken',
    );
    final json = _decodeOrThrow(response, 'Token-Erneuerung fehlgeschlagen');
    _idToken = json['id_token'] as String;
    _refreshToken = json['refresh_token'] as String;
    _uid = json['user_id'] as String;
    _setExpiry(json['expires_in'] as String?);
    await _persist();
  }

  void _setExpiry(String? expiresInSeconds) {
    final seconds = int.tryParse(expiresInSeconds ?? '') ?? 3600;
    // 5 Minuten Puffer, damit laufende Requests nicht in den Ablauf laufen.
    _tokenExpiry = DateTime.now().add(Duration(seconds: seconds - 300));
  }

  Future<void> _persist() =>
      saveCredentials(jsonEncode({'uid': _uid, 'refreshToken': _refreshToken}));

  Map<String, dynamic> _decodeOrThrow(http.Response response, String message) {
    if (response.statusCode != 200) {
      throw Exception('$message (${response.statusCode}): ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
