import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:belong/data/mock/mock_database.dart';
import 'package:belong/data/providers.dart';
import 'package:belong/main.dart';

void main() {
  Widget appWithoutLatency() {
    return ProviderScope(
      overrides: [
        // Tests laufen immer gegen die Mock-Datenschicht (Plan B) …
        dataBackendProvider.overrideWithValue(DataBackend.mock),
        // … und ohne simulierte Latenz, damit sie nicht auf Timer warten.
        mockDatabaseProvider
            .overrideWithValue(MockDatabase(latency: Duration.zero)),
      ],
      child: const BelongApp(),
    );
  }

  testWidgets('Onboarding wird ohne Profil angezeigt', (tester) async {
    await tester.pumpWidget(appWithoutLatency());
    await tester.pumpAndSettle();

    expect(find.text('Schön, dass du da bist.'), findsOneWidget);
    expect(find.text('Ganz anonym'), findsOneWidget);

    // Der Button liegt je nach Viewport unterhalb des sichtbaren Bereichs.
    await tester.scrollUntilVisible(find.text("Los geht's"), 120);
    expect(find.text("Los geht's"), findsOneWidget);
  });

  testWidgets('Anonymer Einstieg führt in den Feed', (tester) async {
    await tester.pumpWidget(appWithoutLatency());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text("Los geht's"), 120);
    await tester.tap(find.text("Los geht's"));
    await tester.pumpAndSettle();

    // Feed mit Mock-Aktivitäten ist sichtbar.
    expect(find.text('Lauftreff Karlsaue'), findsOneWidget);
    expect(find.text('Ich bin dabei'), findsWidgets);
  });
}
