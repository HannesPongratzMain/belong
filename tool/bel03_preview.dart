// Sichtprüfung ohne Gerät (siehe tool/preview_shots.dart): treibt die App
// (Mock-Backend) durch den BEL-03-Sichtbarkeitsfluss — gesperrter Feed,
// Verifizierungs-Sheet, freigeschalteter Feed, exakter Ort nach Beitritt.
//
//   flutter test tool/bel03_preview.dart
//
// Die PNGs landen in build/previews/ (gitignoriert).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart' show TextField;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:belong/data/mock/mock_database.dart';
import 'package:belong/data/providers.dart';
import 'package:belong/main.dart';

const _outDir = 'build/previews';
final _rootKey = GlobalKey();

Future<void> _shot(WidgetTester tester, String name) async {
  final boundary = _rootKey.currentContext!.findRenderObject()!
      as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_outDir/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

Finder _fieldWithHint(String hint) => find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.hintText == hint);

void main() {
  setUpAll(() async {
    const fonts = {
      'Inter': [
        'assets/fonts/Inter-Regular.ttf',
        'assets/fonts/Inter-Medium.ttf',
        'assets/fonts/Inter-SemiBold.ttf',
        'assets/fonts/Inter-Bold.ttf',
      ],
      'packages/lucide_icons_flutter/Lucide': [
        'packages/lucide_icons_flutter/assets/lucide.ttf',
      ],
    };
    for (final entry in fonts.entries) {
      final loader = FontLoader(entry.key);
      for (final asset in entry.value) {
        loader.addFont(rootBundle.load(asset));
      }
      await loader.load();
    }
  });

  testWidgets('BEL-03: gesperrt → verifizieren → freigeschaltet',
      (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      RepaintBoundary(
        key: _rootKey,
        child: ProviderScope(
          overrides: [
            dataBackendProvider.overrideWithValue(DataBackend.mock),
            mockDatabaseProvider
                .overrideWithValue(MockDatabase(latency: Duration.zero)),
          ],
          child: const BelongApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Onboarding → Feed. Frisches Profil ist unverifiziert.
    await tester.scrollUntilVisible(find.text("Los geht's"), 120);
    await tester.tap(find.text("Los geht's"));
    await tester.pumpAndSettle();

    // 1) Feed gesperrt: nur Stadtteil, gedimmter Join-Button mit Lock-Icon.
    expect(find.text('Mitte'), findsWidgets);
    expect(find.text('Orangerie, Karlsaue'), findsNothing);
    await _shot(tester, 'bel03-01-feed-locked');

    // 2) Tap auf den gesperrten Button → direkt ins Verifizierungs-Sheet.
    await tester.tap(find.text('Ich bin dabei').first);
    await tester.pumpAndSettle();
    expect(find.text('Nummer bestätigen'), findsOneWidget);
    await _shot(tester, 'bel03-02-locked-opens-verify-sheet');

    await tester.enterText(_fieldWithHint('+49 …'), '+49 151 00000000');
    await tester.pump();
    await tester.tap(find.text('Code senden'));
    await tester.pumpAndSettle();
    await _shot(tester, 'bel03-03-verify-code-step');

    await tester.enterText(_fieldWithHint('000000'), '123456');
    await tester.pump();
    await tester.tap(find.text('Bestätigen'));
    await tester.pumpAndSettle();
    expect(find.text('Verifiziert'), findsWidgets);
    await _shot(tester, 'bel03-05-verify-done');
    // Sheet wurde vom gesperrten Feed-Button geöffnet → schließt zurück in
    // den Feed (nicht ins Profil).
    await tester.tap(find.text('Fertig'));
    await tester.pumpAndSettle();

    // 3) Zurück im Feed: normaler Join-Button, kein Lock mehr.
    await _shot(tester, 'bel03-06-feed-unlocked');
    await tester.tap(find.text('Ich bin dabei').first);
    await tester.pumpAndSettle();
    expect(find.text('Du bist dabei'), findsWidgets);

    // 4) Profil zeigt den grünen Verifiziert-Status.
    await tester.tap(find.text('Du'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Verifiziert — du kannst'), findsOneWidget);
    await _shot(tester, 'bel03-07-profile-verified');
    await tester.tap(find.text('Entdecken'));
    await tester.pumpAndSettle();

    // 5) Detail der beigetretenen Aktivität: exakter Ort sichtbar.
    await tester.tap(find.text('Lauftreff Karlsaue').first);
    await tester.pumpAndSettle();
    // Detail zeigt exakte Adresse + Stadtteil kombiniert ("… · Mitte").
    expect(find.textContaining('Orangerie, Karlsaue'), findsOneWidget);
    await _shot(tester, 'bel03-08-detail-precise-address');
  });
}
