import 'json_utils.dart';

/// Angenommene Freundschaft — Nickname wird beim Annehmen denormalisiert
/// gespeichert (kein Cross-User-Read auf `users/{uid}` möglich/nötig).
class Friend {
  const Friend({
    required this.userId,
    required this.nickname,
    required this.since,
  });

  final String userId;
  final String nickname;
  final DateTime since;

  factory Friend.fromJson(Map<String, dynamic> json) => Friend(
        userId: json['userId'] as String,
        nickname: json['nickname'] as String,
        since: parseDateTime(json['since']),
      );

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'since': since.toIso8601String(),
      };
}
