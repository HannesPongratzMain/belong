import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:belong/data/mock/mock_database.dart';
import 'package:belong/data/providers.dart';
import 'package:belong/main.dart';

void main() {
  testWidgets(
      'Gesperrter Join-Button führt zur Verifizierung — kein Beitritt ohne '
      'sie', (tester) async {
    final db = MockDatabase(latency: Duration.zero);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        dataBackendProvider.overrideWithValue(DataBackend.mock),
        mockDatabaseProvider.overrideWithValue(db),
      ],
      child: const BelongApp(),
    ));
    await tester.pumpAndSettle();

    // Anonymer Einstieg (inkl. 18+-Bestätigung) — Profil ist danach
    // angelegt, aber unverifiziert.
    await tester.scrollUntilVisible(find.text("Los geht's"), 120);
    await tester.tap(find.text('Ich bin mindestens 18 Jahre alt.'));
    await tester.pump();
    await tester.tap(find.text("Los geht's"));
    await tester.pumpAndSettle();

    expect(find.text('Nummer bestätigen'), findsNothing);

    await tester.tap(find.text('Ich bin dabei').first);
    await tester.pumpAndSettle();

    // Tap öffnet direkt das Verifizierungs-Sheet …
    expect(find.text('Nummer bestätigen'), findsOneWidget);
    // … nicht irgendeinen Beitritt.
    expect(db.joinedIds, isEmpty);

    // Sheet schließen, ohne zu verifizieren → weiterhin kein Beitritt.
    await tester.tap(find.bySemanticsLabel('Schließen'));
    await tester.pumpAndSettle();
    expect(db.joinedIds, isEmpty);
    expect(db.profile?.verificationLevel.isVerified ?? false, isFalse);
  });
}
