import 'package:web/web.dart' as web;

/// Persistenz der anonymen Sitzung im Browser: localStorage.
Future<String?> loadCredentials() async =>
    web.window.localStorage.getItem('belong_session');

Future<void> saveCredentials(String json) async =>
    web.window.localStorage.setItem('belong_session', json);
