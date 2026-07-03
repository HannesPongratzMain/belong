/// Konfiguration der Firebase-Anbindung (REST, ohne native Plugins).
///
/// Es wird bewusst nur die Realtime Database + Anonymous Auth über die
/// REST-API genutzt: das läuft ohne App-Registrierung und ohne
/// google-services.json auf allen Plattformen — inklusive Windows-Desktop,
/// das die FlutterFire-Datenbank-SDKs nicht unterstützen.
abstract final class BelongFirebaseConfig {
  /// Web-API-Schlüssel des Firebase-Projekts
  /// (Konsole → Projekteinstellungen → Allgemein → Web-API-Schlüssel).
  static const apiKey = String.fromEnvironment(
    'BELONG_FIREBASE_API_KEY',
    defaultValue: 'AIzaSyBErAkXmrIJg9sHvn4HRlAWnJSyElad91E',
  );

  /// URL der Realtime-Database-Instanz.
  static const databaseUrl =
      'https://belong-c2758-default-rtdb.europe-west1.firebasedatabase.app';

  /// Solange kein API-Key hinterlegt ist, fällt die App automatisch auf
  /// die Mock-Datenschicht zurück (Plan B) — sie bleibt also immer lauffähig.
  static bool get isConfigured => !apiKey.startsWith('<');
}
