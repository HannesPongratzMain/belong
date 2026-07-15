import '../../domain/models/anonymity_level.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/verification_level.dart';
import '../repositories/auth_repository.dart';
import '../repositories/exceptions.dart';
import 'mock_database.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._db);

  final MockDatabase _db;

  @override
  Future<UserProfile?> currentProfile() => _db(() => _db.profile);

  @override
  Future<String> suggestNickname() async => _db.randomNickname();

  @override
  Future<UserProfile> completeOnboarding({
    required AnonymityLevel level,
    required String nickname,
    required bool ageConfirmed,
    List<String> interests = const [],
  }) {
    return _db(() {
      // Spiegelt die Database Rules: ohne Altersbestätigung kein Profil.
      if (!ageConfirmed) throw const AgeConfirmationRequiredException();
      final profile = UserProfile(
        id: MockDatabase.currentUserId,
        nickname: nickname,
        anonymityLevel: level,
        // Interessen werden nur bei der passenden Stufe überhaupt gespeichert
        // (Datensparsamkeit auf Modell-Ebene, nicht nur im UI).
        interests: level == AnonymityLevel.nicknameInterests ? interests : const [],
        ageConfirmed: true,
      );
      _db.profile = profile;
      return profile;
    });
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) {
    return _db(() {
      final sanitized = profile.anonymityLevel == AnonymityLevel.nicknameInterests
          ? profile
          : profile.copyWith(interests: const []);
      _db.profile = sanitized;
      return sanitized;
    });
  }

  @override
  Future<UserProfile> verifyPhone() {
    return _db(() {
      final current = _db.profile;
      if (current == null) throw StateError('Kein Profil angelegt.');
      final updated =
          current.copyWith(verificationLevel: VerificationLevel.phone);
      _db.profile = updated;
      return updated;
    });
  }

  @override
  Future<UserProfile> confirmAge() {
    return _db(() {
      final current = _db.profile;
      if (current == null) throw StateError('Kein Profil angelegt.');
      final updated = current.copyWith(ageConfirmed: true);
      _db.profile = updated;
      return updated;
    });
  }
}
