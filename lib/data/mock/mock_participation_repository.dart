import 'dart:async';

import '../../domain/models/chat_message.dart';
import '../../domain/models/participation.dart';
import '../../domain/models/verification_level.dart';
import '../repositories/exceptions.dart';
import '../repositories/participation_repository.dart';
import 'mock_database.dart';

class MockParticipationRepository implements ParticipationRepository {
  MockParticipationRepository(this._db);

  final MockDatabase _db;

  @override
  Future<List<Participation>> myParticipations() =>
      _db(() => _db.participations.values.toList()
        ..sort((a, b) => a.joinedAt.compareTo(b.joinedAt)));

  @override
  Stream<Set<String>> watchJoinedActivityIds() async* {
    yield _db.joinedIds;
    yield* _db.joinedIdsChanges.stream;
  }

  @override
  Future<void> join(String activityId) {
    return _db(() {
      if (_db.participations.containsKey(activityId)) return;
      if (_db.profile?.verificationLevel != VerificationLevel.phone) {
        throw const VerificationRequiredException();
      }
      final activity = _db.requireActivity(activityId);
      if (activity.isFull) throw const ActivityFullException();

      _db.participations[activityId] =
          Participation(activityId: activityId, joinedAt: DateTime.now());
      _db.replaceActivity(
        activity.copyWith(participantCount: activity.participantCount + 1),
      );
      _db.joinedIdsChanges.add(_db.joinedIds);

      // Der Beitritt wird im Gruppenchat als System-Notiz sichtbar —
      // natürlich nur mit dem Spitznamen.
      final nickname = _db.profile?.nickname ?? 'jemand';
      _db.addMessage(ChatMessage(
        id: _db.nextId('m'),
        activityId: activityId,
        senderId: MockDatabase.currentUserId,
        senderNickname: nickname,
        type: ChatMessageType.system,
        text: '$nickname ist jetzt dabei',
        sentAt: DateTime.now(),
      ));
    });
  }

  @override
  Future<void> leave(String activityId) {
    return _db(() {
      final removed = _db.participations.remove(activityId);
      if (removed == null) return;
      final activity = _db.requireActivity(activityId);
      _db.replaceActivity(
        activity.copyWith(participantCount: activity.participantCount - 1),
      );
      _db.joinedIdsChanges.add(_db.joinedIds);

      final nickname = _db.profile?.nickname ?? 'jemand';
      _db.addMessage(ChatMessage(
        id: _db.nextId('m'),
        activityId: activityId,
        senderId: MockDatabase.currentUserId,
        senderNickname: nickname,
        type: ChatMessageType.system,
        text: '$nickname ist wieder raus',
        sentAt: DateTime.now(),
      ));
    });
  }
}
