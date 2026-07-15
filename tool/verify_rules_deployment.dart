// ignore_for_file: avoid_print
// Live-Beweis, dass die BEL-03-Regeln auf dem echten Firebase-Projekt
// durchgesetzt werden (nicht nur im Client ausgeblendet) — erst nach dem
// Deploy von firebase/database.rules.json ausführen:
//
//   dart run tool/verify_rules_deployment.dart
//
// Legt ein frisches (unverifiziertes) anonymes Test-Konto an und prüft:
//   1) GET activities/<id>/precise  → muss 401/403 sein (keine Teilnahme)
//   2) PUT activityParticipants/<id>/<uid> → muss 401/403 sein (nicht
//      verifiziert)
// Beides sind reine Lese-/eigene-Schreibversuche gegen ein Wegwerf-Konto —
// nichts an bestehenden Daten wird verändert.
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:belong/data/firebase/firebase_config.dart';

Future<void> main() async {
  final http_ = http.Client();
  print('Projekt: ${BelongFirebaseConfig.databaseUrl}');

  print('\n1) Anonymes Test-Konto anlegen …');
  final signUp = await http_.post(
    Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp'
        '?key=${BelongFirebaseConfig.apiKey}'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'returnSecureToken': true}),
  );
  if (signUp.statusCode != 200) {
    print('   FEHLGESCHLAGEN (${signUp.statusCode}): ${signUp.body}');
    return;
  }
  final auth = jsonDecode(signUp.body) as Map<String, dynamic>;
  final token = auth['idToken'] as String;
  final uid = auth['localId'] as String;
  print('   OK — uid=$uid (unverifiziert, keine Teilnahme an irgendwas)');

  print('\n2) Eine existierende Aktivität suchen …');
  final list = await http_.get(Uri.parse(
      '${BelongFirebaseConfig.databaseUrl}/activities.json?shallow=true&auth=$token'));
  if (list.statusCode != 200) {
    print('   FEHLGESCHLAGEN (${list.statusCode}): ${list.body}');
    return;
  }
  final ids = (jsonDecode(list.body) as Map<String, dynamic>?)?.keys.toList();
  if (ids == null || ids.isEmpty) {
    print('   Keine Aktivitäten im Projekt — nichts zu prüfen. Lege in der '
        'App zuerst eine Aktivität an (mit einem anderen, verifizierten '
        'Konto) und starte das Skript erneut.');
    return;
  }
  final activityId = ids.first;
  print('   Teste gegen: $activityId');

  print('\n3) GET activities/$activityId/precise (sollte 401/403 sein) …');
  final preciseRead = await http_.get(Uri.parse(
      '${BelongFirebaseConfig.databaseUrl}/activities/$activityId/precise.json?auth=$token'));
  final readDenied = preciseRead.statusCode == 401 || preciseRead.statusCode == 403;
  print(readDenied
      ? '   ✅ verweigert (${preciseRead.statusCode}) — precise ist serverseitig geschützt.'
      : '   ❌ NICHT verweigert (${preciseRead.statusCode}): ${preciseRead.body}\n'
          '      → Rules vermutlich noch nicht deployed, siehe README-Hinweis.');

  print('\n4) PUT activityParticipants/$activityId/$uid (sollte 401/403 sein, '
      'da unverifiziert) …');
  final joinWrite = await http_.put(
    Uri.parse(
        '${BelongFirebaseConfig.databaseUrl}/activityParticipants/$activityId/$uid.json?auth=$token'),
    body: 'true',
  );
  final writeDenied = joinWrite.statusCode == 401 || joinWrite.statusCode == 403;
  print(writeDenied
      ? '   ✅ verweigert (${joinWrite.statusCode}) — Beitritt ohne Verifizierung ist serverseitig gesperrt.'
      : '   ❌ NICHT verweigert (${joinWrite.statusCode}): ${joinWrite.body}\n'
          '      → Rules vermutlich noch nicht deployed, siehe README-Hinweis.');

  http_.close();
  print('\n${readDenied && writeDenied ? 'Alles grün.' : 'Mindestens eine Prüfung ist durchgefallen — siehe oben.'}');
}
