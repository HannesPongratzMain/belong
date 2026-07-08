import 'anonymity_level.dart';
import 'verification_level.dart';

/// Minimales Nutzerprofil — bewusst ohne Klarname, E-Mail oder Foto.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.nickname,
    required this.anonymityLevel,
    this.interests = const [],
    this.verificationLevel = VerificationLevel.none,
  });

  final String id;
  final String nickname;
  final AnonymityLevel anonymityLevel;

  /// Nur bei [AnonymityLevel.nicknameInterests] sichtbar für andere.
  final List<String> interests;

  /// Freischaltung für Beitreten/Hosten/exakte Orte — unabhängig von
  /// [anonymityLevel] (die Sichtbarkeits-Stufe gegenüber anderen).
  final VerificationLevel verificationLevel;

  UserProfile copyWith({
    String? nickname,
    AnonymityLevel? anonymityLevel,
    List<String>? interests,
    VerificationLevel? verificationLevel,
  }) =>
      UserProfile(
        id: id,
        nickname: nickname ?? this.nickname,
        anonymityLevel: anonymityLevel ?? this.anonymityLevel,
        interests: interests ?? this.interests,
        verificationLevel: verificationLevel ?? this.verificationLevel,
      );

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        nickname: json['nickname'] as String,
        anonymityLevel: AnonymityLevel.fromJson(json['anonymityLevel'] as String),
        interests: (json['interests'] as List<dynamic>? ?? []).cast<String>(),
        verificationLevel:
            VerificationLevel.fromJson(json['verificationLevel'] as String?),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'anonymityLevel': anonymityLevel.toJson(),
        'interests': interests,
        'verificationLevel': verificationLevel.toJson(),
      };
}
