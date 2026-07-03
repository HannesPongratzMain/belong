import '../../domain/models/activity.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/participation.dart';
import '../repositories/participation_repository.dart';
import 'firebase_auth_client.dart';
import 'rtdb_client.dart';

/// One-Click-Join über `/participations/{uid}` mit Spiegel-Index
/// `/activityParticipants/{activityId}` (Grundlage der Chat-Zugriffsregel).
class FirebaseParticipationRepository implements ParticipationRepository {
  FirebaseParticipationRepository(this._auth, this._db);

  final FirebaseAuthClient _auth;
  final RtdbClient _db;

  @override
  Future<List<Participation>> myParticipations() async {
    await _auth.ensureSignedIn();
    final json =
        await _db.get('participations/${_auth.uid}') as Map<String, dynamic>?;
    if (json == null) return const [];
    return [
      for (final entry in json.entries)
        Participation.fromJson({
          'activityId': entry.key,
          ...(entry.value as Map).cast<String, dynamic>(),
        }),
    ]..sort((a, b) => a.joinedAt.compareTo(b.joinedAt));
  }

  @override
  Stream<Set<String>> watchJoinedActivityIds() async* {
    await _auth.ensureSignedIn();
    yield* _db.watch('participations/${_auth.uid}').map(
          (json) => json == null
              ? const <String>{}
              : (json as Map<String, dynamic>).keys.toSet(),
        );
  }

  @override
  Future<void> join(String activityId) async {
    await _auth.ensureSignedIn();
    final uid = _auth.uid;

    // Kapazität prüfen und Zähler konfliktsicher erhöhen (ETag statt
    // Transaktion — REST-API).
    final activityJson = await _db.get('activities/$activityId');
    final activity = Activity.fromJson({
      'id': activityId,
      ...(activityJson as Map).cast<String, dynamic>(),
    });
    if (activity.isFull) throw const ActivityFullException();

    await _db.compareAndSet('activities/$activityId/participantCount',
        (current) => ((current as num?)?.toInt() ?? 0) + 1);

    await _db.patch('', {
      'participations/$uid/$activityId': {
        'joinedAt': DateTime.now().toIso8601String(),
      },
      'activityParticipants/$activityId/$uid': true,
    });

    // Beitritt als System-Notiz — natürlich nur mit Spitznamen.
    await _pushSystemNote(activityId, 'ist jetzt dabei');
  }

  @override
  Future<void> leave(String activityId) async {
    await _auth.ensureSignedIn();
    final uid = _auth.uid;

    // Notiz zuerst — nach dem Austragen wäre der Chat nicht mehr beschreibbar.
    await _pushSystemNote(activityId, 'ist wieder raus');

    await _db.patch('', {
      'participations/$uid/$activityId': null,
      'activityParticipants/$activityId/$uid': null,
    });
    await _db.compareAndSet(
        'activities/$activityId/participantCount',
        (current) =>
            (((current as num?)?.toInt() ?? 1) - 1).clamp(0, 1 << 31));
  }

  Future<void> _pushSystemNote(String activityId, String suffix) async {
    final nickname =
        await _db.get('users/${_auth.uid}/nickname') as String? ?? 'jemand';
    await _db.push('chats/$activityId/messages', {
      'senderId': _auth.uid,
      'senderNickname': nickname,
      'isOrganizer': false,
      'text': '$nickname $suffix',
      'type': ChatMessageType.system.toJson(),
      'sentAt': DateTime.now().toIso8601String(),
    });
  }
}
