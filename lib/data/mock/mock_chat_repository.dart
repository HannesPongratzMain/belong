import 'dart:async';

import '../../domain/models/chat_message.dart';
import '../repositories/chat_repository.dart';
import 'mock_database.dart';

class MockChatRepository implements ChatRepository {
  MockChatRepository(this._db);

  final MockDatabase _db;

  List<ChatMessage> _visibleMessages(String activityId) =>
      (_db.messages[activityId] ?? const [])
          .where((message) => !_db.blockedUserIds.contains(message.senderId))
          .toList();

  @override
  Stream<List<ChatMessage>> watchMessages(String activityId) async* {
    // Inhalte nur für Teilnehmer:innen — auch die Mock-Datenquelle
    // erzwingt die Zugriffsregel, nicht nur die UI.
    if (!_db.participations.containsKey(activityId) &&
        !_db.myActivityIds.contains(activityId)) {
      throw const ChatAccessDeniedException();
    }
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
}
