import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/poll.dart';

/// Nachrichten eines Gruppenchats — der Stream wirft
/// [ChatAccessDeniedException], wenn keine Teilnahme besteht.
final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>(
  (ref, activityId) =>
      ref.watch(chatRepositoryProvider).watchMessages(activityId),
);

/// Umfragen eines Chats, nach Erstellzeit sortiert.
final chatPollsProvider = StreamProvider.family<List<Poll>, String>(
  (ref, activityId) => ref.watch(chatRepositoryProvider).watchPolls(activityId),
);

/// Angepinnte Nachricht eines Chats (`null` = keine).
final pinnedMessageIdProvider = StreamProvider.family<String?, String>(
  (ref, activityId) =>
      ref.watch(chatRepositoryProvider).watchPinnedMessageId(activityId),
);

/// Wer darf Umfragen erstellen — aktuell nur der Host. Einzige Stelle für
/// diese Regel: um sie später auf alle Teilnehmenden zu öffnen, hier
/// `isHost` durch `true` ersetzen (und die Security Rule entsprechend
/// anpassen, siehe `firebase/database.rules.json`).
bool canCreatePoll({required bool isHost}) => isHost;

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

  Future<void> createPoll(
    String activityId, {
    required String question,
    required List<String> options,
    required bool allowMultiple,
  }) =>
      _ref.read(chatRepositoryProvider).createPoll(
            activityId: activityId,
            question: question,
            options: options,
            allowMultiple: allowMultiple,
          );

  Future<void> vote(
    String activityId,
    String pollId, {
    required bool allowMultiple,
    required List<int> selection,
  }) =>
      _ref.read(chatRepositoryProvider).vote(
            activityId: activityId,
            pollId: pollId,
            allowMultiple: allowMultiple,
            selection: selection,
          );

  Future<void> pinMessage(String activityId, String messageId) => _ref
      .read(chatRepositoryProvider)
      .pinMessage(activityId: activityId, messageId: messageId);

  Future<void> unpinMessage(String activityId) =>
      _ref.read(chatRepositoryProvider).unpinMessage(activityId);
}
