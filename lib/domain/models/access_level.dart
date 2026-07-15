import 'verification_level.dart';

/// Detailtiefe, die Feed/Detail/Chat einer Aktivität zeigen dürfen —
/// abgeleitet aus Verifizierung und Teilnahme (BEL-03-Sichtbarkeitsmatrix).
enum AccessLevel {
  /// Anonym/unverifiziert, nicht beigetreten: nur Grobverortung + Zähler,
  /// Aktionen (Beitreten/Hosten) gesperrt.
  locked,

  /// Verifiziert, aber noch nicht beigetreten: Aktionen frei, exakter Ort
  /// bleibt verborgen.
  unlockedNotJoined,

  /// Beigetreten (setzt Verifizierung voraus) oder eigene Aktivität:
  /// volle Detailtiefe.
  joined;

  /// [hasAccess] = beigetreten oder eigene Aktivität — Beitritt setzt
  /// serverseitig bereits `verificationLevel == phone` voraus, ist also
  /// selbst schon ein stärkerer Nachweis als [verificationLevel] allein.
  static AccessLevel derive({
    required VerificationLevel verificationLevel,
    required bool hasAccess,
  }) {
    if (hasAccess) return AccessLevel.joined;
    if (verificationLevel.isVerified) return AccessLevel.unlockedNotJoined;
    return AccessLevel.locked;
  }
}
