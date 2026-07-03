import 'dart:async';

import '../../domain/models/chat_message.dart';
import '../repositories/chat_repository.dart';
import 'firebase_auth_client.dart';
import 'rtdb_client.dart';

/// Gruppenchat über `/chats/{activityId}/messages`.
///
/// Die Zugriffsregel („nur Teilnehmer:innen") erzwingt der Server über die
/// Security Rules; hier wird sie in die Domänen-Exception übersetzt.
class FirebaseChatRepository implements ChatRepository {
  FirebaseChatRepository(this._auth, this._db);

  final FirebaseAuthClient _auth;
  final RtdbClient _db;

  @override
  Stream<List<ChatMessage>> watchMessages(String activityId) {
    late StreamController<List<ChatMessage>> controller;
    StreamSubscription<dynamic>? messagesSub;
    StreamSubscription<dynamic>? blocksSub;

    Map<String, dynamic>? messages;
    var blocked = const <String>{};
    var hasMessages = false;

    void emit() {
      if (!hasMessages) return;
      final list = [
        for (final entry in (messages ?? const <String, dynamic>{}).entries)
          ChatMessage.fromJson({
            'id': entry.key,
            'activityId': activityId,
            ...(entry.value as Map).cast<String, dynamic>(),
          }),
      ]
          .where((message) => !blocked.contains(message.senderId))
          .toList()
        ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
      controller.add(list);
    }

    Future<void> start() async {
      await _auth.ensureSignedIn();
      messagesSub = _db.watch('chats/$activityId/messages').listen((json) {
        messages = (json as Map?)?.cast<String, dynamic>();
        hasMessages = true;
        emit();
      }, onError: (Object error) {
        controller.addError(error is RtdbPermissionDeniedException
            ? const ChatAccessDeniedException()
            : error);
      });
      // Blockierte Personen live ausblenden.
      blocksSub = _db.watch('moderation/blocks/${_auth.uid}').listen((json) {
        blocked = (json as Map?)?.keys.cast<String>().toSet() ?? const {};
        emit();
      }, onError: (_) {});
    }

    controller = StreamController(
      onListen: start,
      onCancel: () async {
        await messagesSub?.cancel();
        await blocksSub?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<void> sendMessage(
      {required String activityId, required String text}) async {
    await _auth.ensureSignedIn();
    final nickname =
        await _db.get('users/${_auth.uid}/nickname') as String? ?? 'jemand';
    final hostId = await _db.get('activities/$activityId/hostId') as String?;
    await _db.push('chats/$activityId/messages', {
      'senderId': _auth.uid,
      'senderNickname': nickname,
      'isOrganizer': hostId == _auth.uid,
      'text': text,
      'type': ChatMessageType.text.toJson(),
      'sentAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> sendMeetupPin(
      {required String activityId, required MeetupPin pin}) async {
    await _auth.ensureSignedIn();
    final nickname =
        await _db.get('users/${_auth.uid}/nickname') as String? ?? 'jemand';
    final hostId = await _db.get('activities/$activityId/hostId') as String?;
    await _db.push('chats/$activityId/messages', {
      'senderId': _auth.uid,
      'senderNickname': nickname,
      'isOrganizer': hostId == _auth.uid,
      // Fallback-Text, falls eine Oberfläche die Karte nicht rendert.
      'text': 'Treffpunkt: ${pin.placeName}',
      'type': ChatMessageType.meetupPin.toJson(),
      'pin': pin.toJson(),
      'sentAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> reportMessage(String messageId) async {
    await _auth.ensureSignedIn();
    await _db.push('moderation/reports', {
      'messageId': messageId,
      'reporterId': _auth.uid,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> blockUser(String userId) async {
    await _auth.ensureSignedIn();
    await _db.put('moderation/blocks/${_auth.uid}/$userId', true);
  }

  @override
  Future<void> muteChat(String activityId) async {
    await _auth.ensureSignedIn();
    await _db.put('moderation/mutes/${_auth.uid}/$activityId', true);
  }

  @override
  Future<bool> isMuted(String activityId) async {
    await _auth.ensureSignedIn();
    final value = await _db.get('moderation/mutes/${_auth.uid}/$activityId');
    return value == true;
  }
}
