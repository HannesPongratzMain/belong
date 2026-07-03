import 'dart:async';

import '../../domain/models/activity.dart';
import '../../domain/models/feed_filter.dart';
import '../repositories/activity_repository.dart';
import 'mock_database.dart';

class MockActivityRepository implements ActivityRepository {
  MockActivityRepository(this._db);

  final MockDatabase _db;

  @override
  Future<List<Activity>> fetchActivities(FeedFilter filter) {
    return _db(() {
      if (_db.failNextFeedFetch) {
        _db.failNextFeedFetch = false;
        throw Exception('Simulierter Netzwerkfehler');
      }
      final now = DateTime.now();
      final result = _db.activities
          .where((activity) => activity.startsAt.isAfter(now))
          .where((activity) => filter.matches(activity, now: now))
          .toList()
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
      return result;
    });
  }

  @override
  Future<Activity> activityById(String id) => _db(() => _db.requireActivity(id));

  @override
  Stream<Activity> watchActivity(String id) async* {
    yield _db.requireActivity(id);
    yield* _db.activityChanges.stream.where((activity) => activity.id == id);
  }

  @override
  Future<Activity> createActivity(ActivityDraft draft) {
    return _db(() {
      final activity = Activity(
        id: _db.nextId('a'),
        title: draft.title,
        description: draft.description,
        category: draft.category,
        locationName: draft.isOnline ? null : draft.locationName,
        isOnline: draft.isOnline,
        // Neue Aktivitäten erscheinen im Standard-Feed („Ganz Kassel").
        area: 'Mitte',
        startsAt: draft.startsAt,
        capacity: draft.capacity,
        // Wer startet, ist automatisch dabei.
        participantCount: 1,
        hostId: MockDatabase.currentUserId,
      );
      _db.activities.add(activity);
      _db.myActivityIds.add(activity.id);
      return activity;
    });
  }

  @override
  Future<List<Activity>> myActivities() {
    return _db(() => _db.activities
        .where((activity) => _db.myActivityIds.contains(activity.id))
        .toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt)));
  }
}
