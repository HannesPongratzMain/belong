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
import 'package:belong/domain/models/activity.dart';
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
    // Echte Fonts statt Test-Platzhalter — sonst sind die
    // Screenshots nicht aussagekräftig.
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

  testWidgets('Host-Werkzeuge: Bearbeiten, Absagen, Erinnerung',
      (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // Eigene Aktivität direkt in die Mock-DB legen — startet „in 2 h",
    // damit auch die In-App-Erinnerung sichtbar wird.
    final db = MockDatabase(latency: Duration.zero);
    db.activities.add(Activity(
      id: 'a-mine',
      title: 'Boule im Park',
      description: 'Kugeln sind da — einfach vorbeikommen.',
      category: ActivityCategory.draussen,
      precise: const PreciseLocation(address: 'Fuldaaue, Boulebahn'),
      area: 'Mitte',
      startsAt: DateTime.now().add(const Duration(hours: 2, minutes: 5)),
      participantCount: 1,
      hostId: MockDatabase.currentUserId,
    ));
    db.myActivityIds.add('a-mine');

    await tester.pumpWidget(
      RepaintBoundary(
        key: _rootKey,
        child: ProviderScope(
          overrides: [
            dataBackendProvider.overrideWithValue(DataBackend.mock),
            mockDatabaseProvider.overrideWithValue(db),
          ],
          child: const BelongApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text("Los geht's"), 120);
    await tester.tap(find.text("Los geht's"));
    await tester.pumpAndSettle();

    // Chats-Tab: Sunflower-Pill „in 2 h" als Erinnerung.
    await tester.tap(find.text('Chats'));
    await tester.pumpAndSettle();
    expect(find.text('in 2 h'), findsOneWidget);
    await _shot(tester, 'chats-reminder');

    // Detail der eigenen Aktivität: Host-Werkzeuge sichtbar.
    await tester.tap(find.text('Boule im Park'));
    await tester.pumpAndSettle();
    // Der Chats-Tab öffnet den Chat — zurück und über den Feed einsteigen.
    if (find.byType(ActivityDetailScreen).evaluate().isEmpty) {
      await tester.tap(find.bySemanticsLabel('Zurück').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entdecken'));
      await tester.pumpAndSettle();
      await _scrollTo(
          tester, find.text('Boule im Park'), find.byType(FeedScreen));
      await tester.tap(find.text('Boule im Park'));
      await tester.pumpAndSettle();
    }
    final detail = find.byType(ActivityDetailScreen);
    final editButton =
        find.descendant(of: detail, matching: find.text('Bearbeiten'));
    await _scrollTo(tester, editButton, detail);
    await _shot(tester, 'host-tools');

    // Bearbeiten: gleiche Maske, vorbefüllt.
    await tester.tap(editButton);
    await tester.pumpAndSettle();
    expect(find.text('Aktivität bearbeiten'), findsOneWidget);
    expect(find.text('Boule im Park'), findsWidgets);
    await _shot(tester, 'edit-sheet');
    await tester.tap(find.bySemanticsLabel('Schließen'));
    await tester.pumpAndSettle();

    // Absagen mit Rückfrage → Banner statt Join-Zustand.
    final cancelButton =
        find.descendant(of: detail, matching: find.text('Aktivität absagen'));
    await _scrollTo(tester, cancelButton, detail);
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ja, absagen'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Abgesagt — diese Aktivität'), findsOneWidget);
    await _shot(tester, 'cancelled');
  });
}
