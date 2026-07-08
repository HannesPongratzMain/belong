import 'dart:io';

/// Persistenz der anonymen Sitzung auf Mobile/Desktop: eine kleine Datei
/// im App-/Benutzerdatenverzeichnis (ohne path_provider-Plugin).
File _credentialFile() {
  final base = Platform.environment['APPDATA'] ??
      Platform.environment['HOME'] ??
      Directory.systemTemp.path;
  return File('$base${Platform.pathSeparator}belong_session.json');
}

Future<String?> loadCredentials() async {
  try {
    final file = _credentialFile();
    if (!await file.exists()) return null;
    return await file.readAsString();
  } on IOException {
    return null;
  }
}

Future<void> saveCredentials(String json) async {
  try {
    await _credentialFile().writeAsString(json);
  } on IOException {
    // Ohne Persistenz startet die Sitzung beim nächsten Mal neu — verkraftbar.
  }
}
