import 'json_utils.dart';

/// Eingehende Freundschaftsanfrage — nur zwischen verifizierten Mitgliedern.
///
/// Bewusst schlank (kein Status-Feld): Ablehnen löscht den Eintrag einfach
/// wieder, statt einen "declined"-Zustand zu speichern (Datensparsamkeit,
/// gleiches Prinzip wie bei [Participation]).
class FriendRequest {
  const FriendRequest({
    required this.fromUserId,
    required this.fromNickname,
    required this.createdAt,
  });

  final String fromUserId;
  final String fromNickname;
  final DateTime createdAt;

  factory FriendRequest.fromJson(Map<String, dynamic> json) => FriendRequest(
        fromUserId: json['fromUserId'] as String,
        fromNickname: json['fromNickname'] as String,
        createdAt: parseDateTime(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'fromNickname': fromNickname,
        'createdAt': createdAt.toIso8601String(),
      };
}
