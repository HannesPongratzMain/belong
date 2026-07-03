import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/models/chat_message.dart';

/// Nachrichten eines Gruppenchats — der Stream wirft
/// [ChatAccessDeniedException], wenn keine Teilnahme besteht.
final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>(
  (ref, activityId) =>
      ref.watch(chatRepositoryProvider).watchMessages(activityId),
);

/// Aktionen des Schutz-Sheets (Melden / Blockieren / Stummschalten)
/// und das Senden von Nachrichten.
final chatActionsProvider = Provider<ChatActions>((ref) => ChatActions(ref));

class ChatActions {
  const ChatActions(this._ref);

  final Ref _ref;

  Future<void> send(String activityId, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return Future.value();
    return _ref
        .read(chatRepositoryProvider)
        .sendMessage(activityId: activityId, text: trimmed);
  }

  Future<void> sendMeetupPin(String activityId, MeetupPin pin) => _ref
      .read(chatRepositoryProvider)
      .sendMeetupPin(activityId: activityId, pin: pin);

  Future<void> report(ChatMessage message) =>
      _ref.read(chatRepositoryProvider).reportMessage(message.id);

  Future<void> block(ChatMessage message) =>
      _ref.read(chatRepositoryProvider).blockUser(message.senderId);

  Future<void> mute(String activityId) =>
      _ref.read(chatRepositoryProvider).muteChat(activityId);
}
