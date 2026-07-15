import 'json_utils.dart';

/// Art einer Chat-Nachricht.
enum ChatMessageType {
  text,

  /// Zentrierte System-Pille, z. B. „leise-lerche ist jetzt dabei".
  system,

  /// Treffpunkt-Karte (MeetupPinCard) mit Ort und Zeit.
  meetupPin;

  static ChatMessageType fromJson(String value) =>
      ChatMessageType.values.firstWhere(
        (type) => type.name == value,
        orElse: () => ChatMessageType.text,
      );

  String toJson() => name;
}

/// Treffpunkt-Anhang einer [ChatMessageType.meetupPin]-Nachricht.
class MeetupPin {
  const MeetupPin({
    required this.placeName,
    required this.address,
    required this.timeLabel,
  });

  final String placeName;
  final String address;
  final String timeLabel;

  factory MeetupPin.fromJson(Map<String, dynamic> json) => MeetupPin(
        placeName: json['placeName'] as String,
        address: json['address'] as String,
        timeLabel: json['timeLabel'] as String,
      );

  Map<String, dynamic> toJson() => {
        'placeName': placeName,
        'address': address,
        'timeLabel': timeLabel,
      };
}

/// Nachricht im Gruppenchat einer Aktivität.
///
/// Absender erscheinen ausschließlich mit Spitznamen — so wie im
/// Onboarding gewählt. Es gibt keine Klarnamen im Datenmodell.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.activityId,
    required this.senderId,
    required this.senderNickname,
    required this.text,
    required this.sentAt,
    this.type = ChatMessageType.text,
    this.isOrganizer = false,
    this.pin,
  });

  final String id;
  final String activityId;
  final String senderId;
  final String senderNickname;
  final String text;
  final DateTime sentAt;
  final ChatMessageType type;

  /// Kennzeichnet die Person, die die Aktivität gestartet hat („ORGA").
  final bool isOrganizer;

  final MeetupPin? pin;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        activityId: json['activityId'] as String,
        senderId: json['senderId'] as String,
        senderNickname: json['senderNickname'] as String,
        text: json['text'] as String? ?? '',
        sentAt: parseDateTime(json['sentAt']),
        type: ChatMessageType.fromJson(json['type'] as String? ?? 'text'),
        isOrganizer: json['isOrganizer'] as bool? ?? false,
        pin: json['pin'] == null
            ? null
            : MeetupPin.fromJson(json['pin'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'activityId': activityId,
        'senderId': senderId,
        'senderNickname': senderNickname,
        'text': text,
        'sentAt': sentAt.toIso8601String(),
        'type': type.toJson(),
        'isOrganizer': isOrganizer,
        'pin': pin?.toJson(),
      };
}
