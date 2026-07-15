import 'dart:async';

import '../../domain/models/activity.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/feed_filter.dart';
import '../../domain/models/verification_level.dart';
import '../repositories/activity_repository.dart';
import '../repositories/exceptions.dart';
import 'mock_database.dart';

class MockActivityRepository implements ActivityRepository {
  MockActivityRepository(this._db);

  final MockDatabase _db;

  /// Mögliche Zugriffe des lokalen „me"-Nutzers auf [activity]: gehostet
  /// oder beigetreten — mirror von `activityParticipants`-Mitgliedschaft.
  bool _hasAccess(Activity activity) =>
      _db.myActivityIds.contains(activity.id) ||
      _db.participations.containsKey(activity.id);

  /// Blendet `precise` aus, wie es der Server über die Security Rules
  /// täte — kein reines UI-Ausblenden, auch die Mock-Datenquelle liefert
  /// den exakten Ort nur bei Mitgliedschaft aus.
  Activity _redacted(Activity activity) {
    if (activity.precise == null || _hasAccess(activity)) return activity;
    return Activity(
      id: activity.id,
      title: activity.title,
      description: activity.description,
      category: activity.category,
      isOnline: activity.isOnline,
      area: activity.area,
      startsAt: activity.startsAt,
      capacity: activity.capacity,
      participantCount: activity.participantCount,
      hostId: activity.hostId,
      photoHint: activity.photoHint,
      isCancelled: activity.isCancelled,
    );
  }

  void _requireVerified() {
    if (_db.profile?.verificationLevel != VerificationLevel.phone) {
      throw const VerificationRequiredException();
    }
  }

  @override
  Future<List<Activity>> fetchActivities(FeedFilter filter) {
    return _db(() {
      if (_db.failNextFeedFetch) {
        _db.failNextFeedFetch = false;
        throw Exception('Simulierter Netzwerkfehler');
      }
      final now = DateTime.now();
      final result = _db.activities
          .where((activity) => !activity.isCancelled)
          .where((activity) => activity.startsAt.isAfter(now))
          .where((activity) => filter.matches(activity, now: now))
          .map(_redacted)
          .toList()
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
      return result;
    });
  }

  @override
  Future<Activity> activityById(String id) =>
      _db(() => _redacted(_db.requireActivity(id)));

  @override
  Stream<Activity> watchActivity(String id) async* {
    yield _redacted(_db.requireActivity(id));
    yield* _db.activityChanges.stream
        .where((activity) => activity.id == id)
        .map(_redacted);
  }

  @override
  Future<Activity> createActivity(ActivityDraft draft) {
    return _db(() {
      _requireVerified();
      final activity = Activity(
        id: _db.nextId('a'),
        title: draft.title,
        description: draft.description,
        category: draft.category,
        precise: draft.isOnline
            ? null
            : PreciseLocation(address: draft.locationName!),
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
  Future<Activity> updateActivity(String id, ActivityDraft draft) {
    return _db(() {
      final current = _db.requireActivity(id);
      final updated = Activity(
        id: id,
        title: draft.title,
        description: draft.description,
        category: draft.category,
        precise: draft.isOnline
            ? null
            : PreciseLocation(address: draft.locationName!),
        isOnline: draft.isOnline,
        area: current.area,
        startsAt: draft.startsAt,
        capacity: draft.capacity,
        participantCount: current.participantCount,
        hostId: current.hostId,
        photoHint: current.photoHint,
        isCancelled: current.isCancelled,
      );
      _db.replaceActivity(updated);
      _addHostNote(id, 'hat die Details aktualisiert');
      return updated;
    });
  }

  @override
  Future<Activity> cancelActivity(String id) {
    return _db(() {
      final updated = _db.requireActivity(id).copyWith(isCancelled: true);
      _db.replaceActivity(updated);
      _addHostNote(id, 'hat die Aktivität abgesagt');
      return updated;
    });
  }

  /// System-Notiz des Hosts im Gruppenchat (Absage / Änderung).
  void _addHostNote(String activityId, String suffix) {
    final nickname = _db.profile?.nickname ?? 'jemand';
    _db.addMessage(ChatMessage(
      id: _db.nextId('m'),
      activityId: activityId,
      senderId: MockDatabase.currentUserId,
      senderNickname: nickname,
      type: ChatMessageType.system,
      text: '$nickname $suffix',
      sentAt: DateTime.now(),
    ));
  }

  @override
  Future<List<Activity>> myActivities() {
    return _db(() => _db.activities
        .where((activity) => _db.myActivityIds.contains(activity.id))
        .toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt)));
  }
}
