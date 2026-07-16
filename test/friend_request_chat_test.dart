import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:belong/data/mock/mock_database.dart';
import 'package:belong/data/providers.dart';
import 'package:belong/domain/models/anonymity_level.dart';
import 'package:belong/domain/models/participation.dart';
import 'package:belong/domain/models/user_profile.dart';
import 'package:belong/domain/models/verification_level.dart';
import 'package:belong/features/chat/chat_screen.dart';

void main() {
  testWidgets(
      'Long-Press auf eine fremde Nachricht → "Als Freund anfragen" sendet '
      'eine Anfrage', (tester) async {
    // Wer eine Nachricht im Chat sehen kann, ist bereits Teilnehmer:in und
    // damit verifiziert (BEL-03) — Profil/Teilnahme werden hier direkt
    // gesetzt, statt Onboarding+Beitritt in der UI durchzuspielen.
    final db = MockDatabase(latency: Duration.zero)
      ..profile = const UserProfile(
        id: MockDatabase.currentUserId,
        nickname: 'test-nutzer',
        anonymityLevel: AnonymityLevel.nickname,
        verificationLevel: VerificationLevel.phone,
        ageConfirmed: true,
      )
      ..participations['a-kanutour'] = Participation(
          activityId: 'a-kanutour', joinedAt: DateTime.now());

    await tester.pumpWidget(ProviderScope(
      overrides: [
        dataBackendProvider.overrideWithValue(DataBackend.mock),
        mockDatabaseProvider.overrideWithValue(db),
      ],
      child: const MaterialApp(home: ChatScreen(activityId: 'a-kanutour')),
    ));
    await tester.pumpAndSettle();

    // Nachricht von 'jan_orga' (Organisator, fremd) long-pressen.
    await tester.longPress(find.text('Klar, hab zwei. Treffpunkt ist hier:'));
    await tester.pumpAndSettle();

    expect(find.text('Als Freund anfragen'), findsOneWidget);
    await tester.tap(find.text('Als Freund anfragen'));
    await tester.pumpAndSettle();

    expect(find.text('Anfrage an jan_orga gesendet.'), findsOneWidget);

    // Toast räumt sich nach 2 s selbst ab — Timer sauber auslaufen lassen,
    // damit der Test danach nicht mit einem pending Timer abbricht.
    await tester.pump(const Duration(seconds: 3));
  });
}
