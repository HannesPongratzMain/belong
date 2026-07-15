import 'package:web/web.dart' as web;

/// Browser: öffnet die Karten-Suche zum Treffpunkt in einem neuen Tab —
/// ohne Plugin, das Ziel übernimmt ggf. die installierte Karten-App.
bool openMapsSearch(String query) {
  web.window.open(
    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    '_blank',
  );
  return true;
}
