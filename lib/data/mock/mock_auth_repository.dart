import '../../domain/models/anonymity_level.dart';
import '../../domain/models/user_profile.dart';
import '../repositories/auth_repository.dart';
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
    List<String> interests = const [],
  }) {
    return _db(() {
      final profile = UserProfile(
        id: MockDatabase.currentUserId,
        nickname: nickname,
        anonymityLevel: level,
        // Interessen werden nur bei der passenden Stufe überhaupt gespeichert
        // (Datensparsamkeit auf Modell-Ebene, nicht nur im UI).
        interests: level == AnonymityLevel.nicknameInterests ? interests : const [],
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
}
