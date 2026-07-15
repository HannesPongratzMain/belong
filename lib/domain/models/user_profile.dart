import 'anonymity_level.dart';

/// Minimales Nutzerprofil — bewusst ohne Klarname, E-Mail oder Foto.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.nickname,
    required this.anonymityLevel,
    this.interests = const [],
  });

  final String id;
  final String nickname;
  final AnonymityLevel anonymityLevel;

  /// Nur bei [AnonymityLevel.nicknameInterests] sichtbar für andere.
  final List<String> interests;

  UserProfile copyWith({
    String? nickname,
    AnonymityLevel? anonymityLevel,
    List<String>? interests,
  }) =>
      UserProfile(
        id: id,
        nickname: nickname ?? this.nickname,
        anonymityLevel: anonymityLevel ?? this.anonymityLevel,
        interests: interests ?? this.interests,
      );

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        nickname: json['nickname'] as String,
        anonymityLevel: AnonymityLevel.fromJson(json['anonymityLevel'] as String),
        interests: (json['interests'] as List<dynamic>? ?? []).cast<String>(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'anonymityLevel': anonymityLevel.toJson(),
        'interests': interests,
      };
}
