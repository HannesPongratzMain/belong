// Sichtprüfung ohne Gerät: treibt die App (Mock-Backend) bis in den
// Gruppenchat und legt Screenshots der neuen Chat-Funktionen ab —
// Route-Toast, Treffpunkt-Sheet und die gesendete Treffpunkt-Karte.
//
//   flutter test tool/preview_shots.dart
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
import 'package:belong/features/activity_detail/activity_detail_screen.dart';
import 'package:belong/features/feed/feed_screen.dart';
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

/// Scrollt die vertikale Liste innerhalb von [screen], bis [target] sichtbar
/// ist — Feed & Detail haben mehrere Scrollables (horizontale Chip-Reihen),
/// deshalb reicht das globale [WidgetTester.scrollUntilVisible] nicht.
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
    // Echte Handoff-Fonts statt Test-Platzhalter — sonst sind die
    // Screenshots nicht aussagekräftig.
    const fonts = {
      'Luckiest Guy': ['assets/fonts/LuckiestGuy-Regular.ttf'],
      'Hedvig Letters Serif': ['assets/fonts/HedvigLettersSerif-Regular.ttf'],
      'Hanken Grotesk': [
        'assets/fonts/HankenGrotesk-Regular.ttf',
        'assets/fonts/HankenGrotesk-Medium.ttf',
        'assets/fonts/HankenGrotesk-SemiBold.ttf',
        'assets/fonts/HankenGrotesk-Bold.ttf',
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

  testWidgets('Chat: Route-Toast, Treffpunkt-Sheet, gesendeter Pin',
      (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // Zwischenablage hat im Test keine Plattform-Seite — stumm bestätigen,
    // damit Clipboard.setData (Route-Pill) nicht in einer Exception endet.
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform, (call) async => null);

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

    // Onboarding → Feed → Kanutour (hat den Meetup-Pin im Chat) → beitreten.
    await tester.scrollUntilVisible(find.text("Los geht's"), 120);
    await tester.tap(find.text("Los geht's"));
    await tester.pumpAndSettle();
    await _scrollTo(
        tester, find.text('Kanutour auf der Fulda'), find.byType(FeedScreen));
    await tester.tap(find.text('Kanutour auf der Fulda'));
    await tester.pumpAndSettle();
    // Der Feed dahinter hat ebenfalls „Ich bin dabei"-Buttons —
    // deshalb auf den Detail-Screen eingrenzen.
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

    // Route-Pill → Adresse kopiert → Toast.
    expect(find.text('Bootsverleih Ahoi'), findsOneWidget);
    await tester.tap(find.text('Route'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Adresse kopiert — füg sie in deine Karten-App ein.'),
        findsOneWidget);
    await _shot(tester, 'route-toast');
    await tester.pumpAndSettle();

    // Standort-Button → Treffpunkt-Sheet ausfüllen.
    await tester.tap(find.bySemanticsLabel('Treffpunkt teilen'));
    await tester.pumpAndSettle();
    await tester.enterText(
        _fieldWithHint('z. B. Café Nordpol'), 'Café Nordpol');
    await tester.enterText(
        _fieldWithHint('z. B. Friedrich-Ebert-Str. 12'), 'Elfbuchenstr. 3');
    await tester.enterText(_fieldWithHint('z. B. Heute · 18:00'), 'Sa 09:30');
    await tester.pump();
    await _shot(tester, 'meetup-sheet');

    // Absenden → neue Treffpunkt-Karte im Chat.
    await tester.tap(find.text('Treffpunkt teilen').last);
    await tester.pumpAndSettle();
    expect(find.text('Café Nordpol'), findsOneWidget);
    await _shot(tester, 'meetup-sent');

    // Den 2-s-Toast-Timer ausklingen lassen — sonst meldet das Test-Binding
    // am Ende einen offenen Timer.
    await tester.pump(const Duration(seconds: 3));
  });
}
