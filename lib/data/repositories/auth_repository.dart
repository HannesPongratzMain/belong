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
  ///
  /// [ageConfirmed] muss `true` sein — belong ist ab 18. Die Datenschicht
  /// lehnt den Abschluss sonst ab (analog serverseitig erzwungen über die
  /// Database Rules), damit die Grenze nicht nur im UI hängt.
  Future<UserProfile> completeOnboarding({
    required AnonymityLevel level,
    required String nickname,
    required bool ageConfirmed,
    List<String> interests,
  });

  /// Bestätigt nachträglich die Altersgrenze (18+) für Profile, die vor
  /// Einführung des Age-Gates angelegt wurden.
  Future<UserProfile> confirmAge();

  /// Aktualisiert Stufe/Spitzname/Interessen — jederzeit möglich.
  Future<UserProfile> updateProfile(UserProfile profile);

  /// Schließt die (simulierte) Telefon-Verifizierung ab — setzt
  /// `verificationLevel` auf `phone`. Es wird bewusst keine Telefonnummer
  /// entgegengenommen oder gespeichert: die Demo-Eingabe in
  /// `verify_phone_sheet.dart` bleibt rein lokal, nur das Ergebnis zählt.
  Future<UserProfile> verifyPhone();
}
