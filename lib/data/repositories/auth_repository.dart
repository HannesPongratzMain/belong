import '../../domain/models/anonymity_level.dart';
import '../../domain/models/user_profile.dart';

/// Anonyme „Authentifizierung" — es gibt bewusst kein Login mit E-Mail
/// oder Passwort. Eine spätere echte Implementierung (z. B. Firebase
/// Anonymous Auth, Supabase) ersetzt nur diese Schnittstelle.
abstract interface class AuthRepository {
  /// Aktuelles Profil oder `null`, wenn das Onboarding noch aussteht.
  Future<UserProfile?> currentProfile();

  /// Liefert einen freundlichen Spitznamen-Vorschlag („stiller-fuchs").
  Future<String> suggestNickname();

  /// Schließt das Onboarding ab und legt das lokale Profil an.
  Future<UserProfile> completeOnboarding({
    required AnonymityLevel level,
    required String nickname,
    List<String> interests,
  });

  /// Aktualisiert Stufe/Spitzname/Interessen — jederzeit möglich.
  Future<UserProfile> updateProfile(UserProfile profile);
}
