import 'dart:math';

import '../../domain/models/anonymity_level.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/verification_level.dart';
import '../repositories/auth_repository.dart';
import '../repositories/exceptions.dart';
import 'firebase_auth_client.dart';
import 'rtdb_client.dart';

/// Profil-Verwaltung über die Realtime Database (`/users/{uid}`),
/// Identität über Firebase Anonymous Auth — weiterhin ohne E-Mail.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._db);

  final FirebaseAuthClient _auth;
  final RtdbClient _db;
  final _random = Random();

  static const _nicknamePool = [
    'stiller-fuchs',
    'flinke-otter',
    'leise-lerche',
    'mutige-meise',
    'wacher-wal',
    'kluge-kraehe',
    'sanfter-luchs',
    'heller-igel',
  ];

  @override
  Future<UserProfile?> currentProfile() async {
    await _auth.ensureSignedIn();
    final json = await _db.get('users/${_auth.uid}');
    if (json == null) return null;
    return UserProfile.fromJson({
      'id': _auth.uid,
      ...(json as Map<String, dynamic>),
    });
  }

  @override
  Future<String> suggestNickname() async =>
      _nicknamePool[_random.nextInt(_nicknamePool.length)];

  @override
  Future<UserProfile> completeOnboarding({
    required AnonymityLevel level,
    required String nickname,
    required bool ageConfirmed,
    List<String> interests = const [],
  }) async {
    // Die Rules lehnen neue Profile ohne `ageConfirmed === true` ohnehin ab —
    // hier zusätzlich früh und mit sprechender Exception.
    if (!ageConfirmed) throw const AgeConfirmationRequiredException();
    await _auth.ensureSignedIn();
    final profile = UserProfile(
      id: _auth.uid,
      nickname: nickname,
      anonymityLevel: level,
      // Datensparsamkeit: Interessen nur bei der passenden Stufe speichern.
      interests:
          level == AnonymityLevel.nicknameInterests ? interests : const [],
      ageConfirmed: true,
    );
    await _db.put('users/${_auth.uid}', {
      ...profile.toJson()..remove('id'),
      'createdAt': DateTime.now().toIso8601String(),
    });
    return profile;
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    final sanitized = profile.anonymityLevel == AnonymityLevel.nicknameInterests
        ? profile
        : profile.copyWith(interests: const []);
    await _db.patch('users/${_auth.uid}', sanitized.toJson()..remove('id'));
    return sanitized;
  }

  @override
  Future<UserProfile> verifyPhone() async {
    await _auth.ensureSignedIn();
    await _db.put(
        'users/${_auth.uid}/verificationLevel', VerificationLevel.phone.toJson());
    final profile = await currentProfile();
    if (profile == null) throw StateError('Kein Profil angelegt.');
    return profile;
  }

  @override
  Future<UserProfile> confirmAge() async {
    await _auth.ensureSignedIn();
    await _db.put('users/${_auth.uid}/ageConfirmed', true);
    final profile = await currentProfile();
    if (profile == null) throw StateError('Kein Profil angelegt.');
    return profile;
  }
}
