import 'dart:async';

import '../../domain/models/chat_message.dart';
import '../../domain/models/poll.dart';
import '../../domain/models/verification_level.dart';
import '../repositories/chat_repository.dart';
import 'mock_database.dart';

class MockChatRepository implements ChatRepository {
  MockChatRepository(this._db);

  final MockDatabase _db;

  /// Teilnehmer:in oder Host — mirror der `activityParticipants`-Prüfung.
  bool _hasAccess(String activityId) =>
      _db.participations.containsKey(activityId) ||
      _db.myActivityIds.contains(activityId);

  List<ChatMessage> _visibleMessages(String activityId) =>
      (_db.messages[activityId] ?? const [])
          .where((message) => !_db.blockedUserIds.contains(message.senderId))
          .toList();

  @override
  Stream<List<ChatMessage>> watchMessages(String activityId) async* {
    // Inhalte nur für Teilnehmer:innen — auch die Mock-Datenquelle
    // erzwingt die Zugriffsregel, nicht nur die UI.
    if (!_hasAccess(activityId)) throw const ChatAccessDeniedException();
    yield _visibleMessages(activityId);
    await for (final change in _db.messageChanges.stream) {
      final relevant = change.activityId == activityId ||
          // Blockieren/Melden löst ein Re-Emit über eine Systemnachricht aus.
          change.activityId == '*';
      if (relevant) yield _visibleMessages(activityId);
    }
  }

  @override
  Future<void> sendMessage({required String activityId, required String text}) {
    return _db(() {
      final profile = _db.profile;
      if (profile == null) return;
      _db.addMessage(ChatMessage(
        id: _db.nextId('m'),
        activityId: activityId,
        senderId: profile.id,
        senderNickname: profile.nickname,
        isOrganizer: _db.myActivityIds.contains(activityId),
        isSenderVerified: profile.verificationLevel == VerificationLevel.phone,
        text: text,
        sentAt: DateTime.now(),
      ));
    });
  }

  @override
  Future<void> sendMeetupPin(
      {required String activityId, required MeetupPin pin}) {
    return _db(() {
      final profile = _db.profile;
      if (profile == null) return;
      _db.addMessage(ChatMessage(
        id: _db.nextId('m'),
        activityId: activityId,
        senderId: profile.id,
        senderNickname: profile.nickname,
        isOrganizer: _db.myActivityIds.contains(activityId),
        isSenderVerified: profile.verificationLevel == VerificationLevel.phone,
        type: ChatMessageType.meetupPin,
        // Fallback-Text, falls eine Oberfläche die Karte nicht rendert.
        text: 'Treffpunkt: ${pin.placeName}',
        pin: pin,
        sentAt: DateTime.now(),
      ));
    });
  }

  @override
  Future<void> reportMessage(String messageId) =>
      _db(() => _db.reportedMessageIds.add(messageId));

  @override
  Future<void> blockUser(String userId) {
    return _db(() {
      _db.blockedUserIds.add(userId);
      // Re-Emit aller offenen Chat-Streams anstoßen.
      _db.messageChanges.add(ChatMessage(
        id: _db.nextId('m'),
        activityId: '*',
        senderId: 'system',
        senderNickname: 'system',
        type: ChatMessageType.system,
        text: '',
        sentAt: DateTime.now(),
      ));
    });
  }

  @override
  Future<void> muteChat(String activityId) =>
      _db(() => _db.mutedChats.add(activityId));

  @override
  Future<bool> isMuted(String activityId) =>
      _db(() => _db.mutedChats.contains(activityId));

  @override
  Stream<List<Poll>> watchPolls(String activityId) async* {
    if (!_hasAccess(activityId)) throw const ChatAccessDeniedException();
    yield List.unmodifiable(_db.polls[activityId] ?? const []);
    await for (final id in _db.pollChanges.stream) {
      if (id == activityId) {
        yield List.unmodifiable(_db.polls[activityId] ?? const []);
      }
    }
  }

  @override
  Future<void> createPoll({
    required String activityId,
    required String question,
    required List<String> options,
    required bool allowMultiple,
  }) {
    // Host-only ist UI- und regelseitig durchgesetzt (wie beim Bearbeiten/
    // Absagen einer Aktivität) — der Mock kennt nur "mich" und vertraut
    // dem Aufrufer, exakt wie MockActivityRepository.updateActivity.
    return _db(() {
      final poll = Poll(
        id: _db.nextId('poll'),
        question: question,
        options: List.unmodifiable(options),
        allowMultiple: allowMultiple,
        createdBy: _db.profile?.id ?? MockDatabase.currentUserId,
        createdAt: DateTime.now(),
      );
      _db.polls.putIfAbsent(activityId, () => []).add(poll);
      _db.pollChanges.add(activityId);
    });
  }

  @override
  Future<void> vote({
    required String activityId,
    required String pollId,
    required bool allowMultiple,
    required List<int> selection,
  }) {
    return _db(() {
      final list = _db.polls[activityId];
      final index = list?.indexWhere((poll) => poll.id == pollId) ?? -1;
      if (list == null || index == -1) return;
      final uid = _db.profile?.id ?? MockDatabase.currentUserId;
      list[index] = list[index]
          .copyWith(votes: {...list[index].votes, uid: selection});
      _db.pollChanges.add(activityId);
    });
  }

  @override
  Stream<String?> watchPinnedMessageId(String activityId) async* {
    if (!_hasAccess(activityId)) throw const ChatAccessDeniedException();
    yield _db.pinnedMessageIds[activityId];
    await for (final id in _db.pinChanges.stream) {
      if (id == activityId) yield _db.pinnedMessageIds[activityId];
    }
  }

  @override
  Future<void> pinMessage({required String activityId, required String messageId}) {
    return _db(() {
      _db.pinnedMessageIds[activityId] = messageId;
      _db.pinChanges.add(activityId);
    });
  }

  @override
  Future<void> unpinMessage(String activityId) {
    return _db(() {
      _db.pinnedMessageIds.remove(activityId);
      _db.pinChanges.add(activityId);
    });
  }
}
