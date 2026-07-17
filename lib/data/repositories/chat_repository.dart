import '../../domain/models/chat_message.dart';
import '../../domain/models/poll.dart';

/// Gruppenchat einer Aktivität.
///
/// Psychologische Sicherheit ist Teil des Vertrags: Nachrichten sind nur
/// für Teilnehmer:innen sichtbar ([watchMessages] wirft
/// [ChatAccessDeniedException] ohne Teilnahme) und Melden/Blockieren/
/// Stummschalten sind Kernfunktionen, keine Nachgedanken.
abstract interface class ChatRepository {
  /// Nachrichten-Stream — nur für Teilnehmer:innen der Aktivität.
  Stream<List<ChatMessage>> watchMessages(String activityId);

  Future<void> sendMessage({required String activityId, required String text});

  /// Teilt einen Treffpunkt als [ChatMessageType.meetupPin]-Nachricht.
  Future<void> sendMeetupPin(
      {required String activityId, required MeetupPin pin});

  Future<void> reportMessage(String messageId);

  /// Blockieren wirkt beidseitig und ohne Ankündigung.
  Future<void> blockUser(String userId);

  Future<void> muteChat(String activityId);

  Future<bool> isMuted(String activityId);

  /// Umfragen eines Chats inkl. aggregierter Stimmen, nach Erstellzeit
  /// sortiert — nur für Teilnehmer:innen.
  Stream<List<Poll>> watchPolls(String activityId);

  /// Neue Umfrage anlegen. Wer das darf, ist an einer Stelle konfiguriert
  /// (siehe `canCreatePoll` in `chat_controller.dart`) — aktuell nur der
  /// Host, serverseitig über die Security Rules erzwungen.
  Future<void> createPoll({
    required String activityId,
    required String question,
    required List<String> options,
    required bool allowMultiple,
  });

  /// Eigene Stimme abgeben/ändern (Upsert) — jede Teilnehmer:in nur für
  /// sich selbst. [selection] sind die gewählten Options-Indizes,
  /// bei Single genau einer.
  Future<void> vote({
    required String activityId,
    required String pollId,
    required bool allowMultiple,
    required List<int> selection,
  });

  /// Angepinnte Nachricht des Chats (`null` = keine) — nur der Host darf
  /// pinnen/lösen (siehe [pinMessage]/[unpinMessage]).
  Stream<String?> watchPinnedMessageId(String activityId);

  Future<void> pinMessage({required String activityId, required String messageId});

  Future<void> unpinMessage(String activityId);
}

class ChatAccessDeniedException implements Exception {
  const ChatAccessDeniedException();
}
