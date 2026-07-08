import 'package:flutter_test/flutter_test.dart';

import 'package:belong/data/mock/mock_activity_repository.dart';
import 'package:belong/data/mock/mock_auth_repository.dart';
import 'package:belong/data/mock/mock_database.dart';
import 'package:belong/data/mock/mock_participation_repository.dart';
import 'package:belong/data/repositories/exceptions.dart';
import 'package:belong/domain/models/activity.dart';
import 'package:belong/domain/models/anonymity_level.dart';
import 'package:belong/domain/models/feed_filter.dart';

/// Die Mock-Datenquelle spiegelt dieselbe Zugriffslogik wie
/// `firebase/database.rules.json` — dieser Test prüft also nicht nur
/// UI-Ausblenden, sondern dass die Datenschicht selbst `precise`
/// zurückhält bzw. Schreibzugriffe ohne Verifizierung ablehnt (analog zum
/// serverseitig durchgesetzten Chat-Zugriff).
void main() {
  late MockDatabase db;
  late MockAuthRepository auth;
  late MockActivityRepository activities;
  late MockParticipationRepository participations;

  final draft = ActivityDraft(
    title: 'Testaktivität',
    category: ActivityCategory.kaffee,
    startsAt: DateTime.now().add(const Duration(days: 1)),
    locationName: 'Irgendwo',
  );

  setUp(() async {
    db = MockDatabase(latency: Duration.zero);
    auth = MockAuthRepository(db);
    activities = MockActivityRepository(db);
    participations = MockParticipationRepository(db);
    await auth.completeOnboarding(
        level: AnonymityLevel.nickname, nickname: 'test-nutzer');
  });

  group('unverifiziert, nicht beigetreten', () {
    test('Feed liefert keine precise-Daten', () async {
      final feedActivities =
          await activities.fetchActivities(const FeedFilter(timeRange: FeedTimeRange.all));
      expect(feedActivities, isNotEmpty);
      expect(feedActivities.every((activity) => activity.precise == null), isTrue);
      // Grobverortung bleibt erhalten.
      expect(
        feedActivities.where((a) => !a.isOnline).every((a) => a.area != null),
        isTrue,
      );
    });

    test('activityById liefert keine precise-Daten', () async {
      final activity = await activities.activityById('a-lauftreff');
      expect(activity.precise, isNull);
      expect(activity.area, isNotNull);
    });

    test('join() wirft VerificationRequiredException', () {
      expect(
        () => participations.join('a-lauftreff'),
        throwsA(isA<VerificationRequiredException>()),
      );
    });

    test('createActivity() wirft VerificationRequiredException', () {
      expect(
        () => activities.createActivity(draft),
        throwsA(isA<VerificationRequiredException>()),
      );
    });
  });

  group('nach simulierter Verifizierung + Beitritt', () {
    test('precise wird für beigetretene Aktivität sichtbar', () async {
      await auth.verifyPhone();
      await participations.join('a-lauftreff');

      final joined = await activities.activityById('a-lauftreff');
      expect(joined.precise, isNotNull);
      expect(joined.precise!.address, isNotEmpty);

      // Andere, nicht beigetretene Aktivitäten bleiben weiterhin redigiert.
      final other = await activities.activityById('a-salsa');
      expect(other.precise, isNull);
    });

    test('createActivity() gelingt und macht precise für den Host sichtbar',
        () async {
      await auth.verifyPhone();
      final created = await activities.createActivity(draft);
      final fetched = await activities.activityById(created.id);
      expect(fetched.precise?.address, 'Irgendwo');
    });
  });
}
