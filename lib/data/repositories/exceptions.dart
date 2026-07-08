/// Serverseitig durchgesetzt (Security Rules) — Beitreten/Hosten setzt
/// `users/{uid}/verificationLevel == 'phone'` voraus. Die Mock-Datenquelle
/// wirft dieselbe Exception, damit UI-Code backend-unabhängig bleibt.
class VerificationRequiredException implements Exception {
  const VerificationRequiredException();
}
