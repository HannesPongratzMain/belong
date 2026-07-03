import '../../domain/models/chat_message.dart';

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
}

class ChatAccessDeniedException implements Exception {
  const ChatAccessDeniedException();
}
