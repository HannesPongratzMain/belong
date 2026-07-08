/// Verifizierungsstufe der Nutzer:in — unabhängig von [AnonymityLevel]
/// (die Sichtbarkeits-*Stufe*, nicht Identitäts-*Prüfung*).
///
/// Uni-Prototyp: „phone" wird über eine simulierte Bestätigung erreicht
/// (siehe `verify_phone_sheet.dart`) — es wird nirgends eine echte
/// Telefonnummer gespeichert, nur das Ergebnis der Prüfung.
enum VerificationLevel {
  none,
  phone;

  static VerificationLevel fromJson(String? value) =>
      VerificationLevel.values.firstWhere(
        (level) => level.name == value,
        orElse: () => VerificationLevel.none,
      );

  String toJson() => name;

  bool get isVerified => this == VerificationLevel.phone;
}
