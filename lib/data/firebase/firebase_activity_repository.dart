import '../../domain/models/activity.dart';
import '../../domain/models/feed_filter.dart';
import '../repositories/activity_repository.dart';
import 'firebase_auth_client.dart';
import 'rtdb_client.dart';

/// Aktivitäten aus `/activities` der Realtime Database.
class FirebaseActivityRepository implements ActivityRepository {
  FirebaseActivityRepository(this._auth, this._db);

  final FirebaseAuthClient _auth;
  final RtdbClient _db;

  /// Demo-Schalter (Long-Press auf die „Kassel"-Pill): lässt den nächsten
  /// Feed-Abruf fehlschlagen, um den Fehler-Zustand vorzuführen.
  bool failNextFeedFetch = false;

  static Activity _fromEntry(String id, Map<String, dynamic> json) =>
      Activity.fromJson({'id': id, ...json});

  Future<List<Activity>> _allActivities() async {
    final json = await _db.get('activities') as Map<String, dynamic>?;
    if (json == null) return const [];
    return [
      for (final entry in json.entries)
        _fromEntry(entry.key, (entry.value as Map).cast<String, dynamic>()),
    ];
  }

  @override
  Future<List<Activity>> fetchActivities(FeedFilter filter) async {
    if (failNextFeedFetch) {
      failNextFeedFetch = false;
      throw Exception('Simulierter Netzwerkfehler');
    }
    final now = DateTime.now();
    final activities = await _allActivities();
    return activities
        .where((activity) => activity.startsAt.isAfter(now))
        .where((activity) => filter.matches(activity, now: now))
        .toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  }

  @override
  Future<Activity> activityById(String id) async {
    final json = await _db.get('activities/$id');
    return _fromEntry(id, (json as Map).cast<String, dynamic>());
  }

  @override
  Stream<Activity> watchActivity(String id) => _db
      .watch('activities/$id')
      .where((json) => json != null)
      .map((json) => _fromEntry(id, (json as Map).cast<String, dynamic>()));

  @override
  Future<Activity> createActivity(ActivityDraft draft) async {
    await _auth.ensureSignedIn();
    final uid = _auth.uid;
    final data = {
      'title': draft.title,
      'description': draft.description,
      'category': draft.category.toJson(),
      'locationName': draft.isOnline ? null : draft.locationName,
      'isOnline': draft.isOnline,
      'area': 'Mitte',
      'startsAt': draft.startsAt.toIso8601String(),
      'capacity': draft.capacity,
      // Wer startet, ist automatisch dabei.
      'participantCount': 1,
      'hostId': uid,
      'createdAt': DateTime.now().toIso8601String(),
    };
    final id = await _db.push('activities', data);
    // Host als Teilnehmer eintragen (Chat-Zugriff via Rules).
    await _db.patch('', {
      'participations/$uid/$id': {
        'joinedAt': DateTime.now().toIso8601String(),
      },
      'activityParticipants/$id/$uid': true,
    });
    return _fromEntry(id, data.cast<String, dynamic>());
  }

  @override
  Future<List<Activity>> myActivities() async {
    await _auth.ensureSignedIn();
    final activities = await _allActivities();
    return activities
        .where((activity) => activity.hostId == _auth.uid)
        .toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  }
}
