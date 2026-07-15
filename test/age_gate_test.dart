import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:belong/data/mock/mock_auth_repository.dart';
import 'package:belong/data/mock/mock_database.dart';
import 'package:belong/data/providers.dart';
import 'package:belong/data/repositories/exceptions.dart';
import 'package:belong/domain/models/anonymity_level.dart';
import 'package:belong/domain/models/user_profile.dart';
import 'package:belong/main.dart';

/// Altersgrenze 18+: das Onboarding verlangt die Selbstbestätigung, die
/// Datenschicht lehnt den Abschluss ohne sie ab (analog zu den Database
/// Rules), und Bestandsprofile ohne Bestätigung landen im Age-Gate.
void main() {
  Widget appWith(MockDatabase db) {
    return ProviderScope(
      overrides: [
        dataBackendProvider.overrideWithValue(DataBackend.mock),
        mockDatabaseProvider.overrideWithValue(db),
      ],
      child: const BelongApp(),
    );
  }

  testWidgets('Onboarding blockiert ohne 18+-Bestätigung', (tester) async {
    await tester.pumpWidget(appWith(MockDatabase(latency: Duration.zero)));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text("Los geht's"), 120);
    await tester.tap(find.text("Los geht's"));
    await tester.pumpAndSettle();

    // Inline-Fehler statt Weiterleitung — wir bleiben im Onboarding.
    expect(find.text('belong ist ab 18 — bitte bestätige kurz dein Alter.'),
        findsOneWidget);
    expect(find.text('Entdecken'), findsNothing);

    // Nach der Bestätigung geht es durch (Tab-Leiste der App-Shell sichtbar).
    await tester.tap(find.text('Ich bin mindestens 18 Jahre alt.'));
    await tester.pump();
    await tester.tap(find.text("Los geht's"));
    await tester.pumpAndSettle();
    expect(find.text('Entdecken'), findsOneWidget);
  });

  testWidgets('Bestandsprofil ohne Bestätigung landet im Age-Gate',
      (tester) async {
    // Profil aus der Zeit vor der Altersgrenze: ageConfirmed fehlt (false).
    final db = MockDatabase(latency: Duration.zero)
      ..profile = const UserProfile(
        id: MockDatabase.currentUserId,
        nickname: 'alt-nutzer',
        anonymityLevel: AnonymityLevel.nickname,
      );
    await tester.pumpWidget(appWith(db));
    await tester.pumpAndSettle();

    expect(find.text('Kurze Frage vorab.'), findsOneWidget);
    expect(find.text('Entdecken'), findsNothing);

    // „Noch nicht 18" zeigt den freundlichen Abschieds-Zustand.
    await tester.tap(find.text('Ich bin noch nicht 18'));
    await tester.pumpAndSettle();
    expect(find.text('Dann bis bald.'), findsOneWidget);

    // Zurück und bestätigen → App-Shell öffnet sich.
    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ich bin 18 oder älter'));
    await tester.pumpAndSettle();
    expect(find.text('Entdecken'), findsOneWidget);
    expect(db.profile?.ageConfirmed, isTrue);
  });

  test('Datenschicht lehnt Onboarding ohne Bestätigung ab', () async {
    final db = MockDatabase(latency: Duration.zero);
    final auth = MockAuthRepository(db);

    await expectLater(
      auth.completeOnboarding(
        level: AnonymityLevel.anonymous,
        nickname: 'stiller-fuchs',
        ageConfirmed: false,
      ),
      throwsA(isA<AgeConfirmationRequiredException>()),
    );
    // Es wurde kein Profil angelegt.
    expect(db.profile, isNull);
  });
}
