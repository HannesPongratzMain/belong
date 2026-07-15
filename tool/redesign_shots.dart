// Sichtprüfung ohne Gerät: legt Screenshots aller Kern-Screens ab —
// Onboarding, Feed, Erstellen-Sheet, Detail, Chat, Chats-Übersicht, Profil.
//
//   flutter test tool/redesign_shots.dart
//
// Die PNGs landen in build/previews/ (gitignoriert).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:belong/data/mock/mock_database.dart';
import 'package:belong/data/providers.dart';
import 'package:belong/features/activity_detail/activity_detail_screen.dart';
import 'package:belong/features/feed/feed_screen.dart';
import 'package:belong/main.dart';

const _outDir = 'build/previews';
final _rootKey = GlobalKey();

Future<void> _shot(WidgetTester tester, String name) async {
  debugPrint('>>> shot: $name');
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

/// Scrollt die vertikale Liste innerhalb von [screen], bis [target] sichtbar
/// ist (wie in tool/preview_shots.dart).
Future<void> _scrollTo(
    WidgetTester tester, Finder target, Finder screen) async {
  final vertical = find.descendant(
    of: screen,
    matching: find.byWidgetPredicate((widget) =>
        widget is Scrollable &&
        axisDirectionToAxis(widget.axisDirection) == Axis.vertical),
  );
  await tester.dragUntilVisible(target, vertical.first, const Offset(0, -120));
}

void main() {
  setUpAll(() async {
    // Echte Fonts statt Test-Platzhalter — inkl. der Lucide-Icon-Font.
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

  testWidgets('Redesign: alle Kern-Screens', (tester) async {
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

    // Onboarding: Grundzustand + aufgeklappte Interessen-Karte.
    await _shot(tester, 'onboarding');
    await tester.tap(find.text('Spitzname + Interessen'));
    await tester.pumpAndSettle();
    await _shot(tester, 'onboarding-interessen');
    await tester.tap(find.text('Ganz anonym'));
    await tester.pumpAndSettle();

    // Feed.
    await tester.scrollUntilVisible(find.text("Los geht's"), 120);
    await tester.tap(find.text("Los geht's"));
    await tester.pumpAndSettle();
    await _shot(tester, 'feed');

    // „Starte was Kleines"-Sheet.
    await tester.tap(find.text('Starten'));
    await tester.pumpAndSettle();
    await _shot(tester, 'create-sheet');
    await tester.tap(find.bySemanticsLabel('Schließen'));
    await tester.pumpAndSettle();

    // Featured Karte direkt im Feed beitreten → Chats-Übersicht hat eine Row.
    await tester.tap(find.text('Ich bin dabei').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chats'));
    await tester.pumpAndSettle();
    await _shot(tester, 'chats');
    await tester.tap(find.text('Du'));
    await tester.pumpAndSettle();
    await _shot(tester, 'profile');
    await tester.tap(find.text('Entdecken'));
    await tester.pumpAndSettle();

    // Detailansicht + Gruppenchat (Kanutour hat Nachrichten & Meetup-Pin).
    // Der Test endet bewusst im Chat: Riverpod 3 pausiert Consumer unter
    // abgedeckten Routen — endet der Test auf der Home-Shell, feuert das
    // Resume beim Teardown mitten im Build (wie in tool/preview_shots.dart).
    await _scrollTo(
        tester, find.text('Kanutour auf der Fulda'), find.byType(FeedScreen));
    await tester.tap(find.text('Kanutour auf der Fulda'));
    await tester.pumpAndSettle();
    await _shot(tester, 'detail');
    final detail = find.byType(ActivityDetailScreen);
    final joinInDetail =
        find.descendant(of: detail, matching: find.text('Ich bin dabei'));
    await _scrollTo(tester, joinInDetail, detail);
    await tester.tap(joinInDetail);
    await tester.pumpAndSettle();
    final chatButton =
        find.descendant(of: detail, matching: find.text('Zum Gruppenchat'));
    await _scrollTo(tester, chatButton, detail);
    await tester.tap(chatButton);
    await tester.pumpAndSettle();
    await _shot(tester, 'chat');
  });
}
