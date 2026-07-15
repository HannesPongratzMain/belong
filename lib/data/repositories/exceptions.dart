/// Serverseitig durchgesetzt (Security Rules) — Beitreten/Hosten setzt
/// `users/{uid}/verificationLevel == 'phone'` voraus. Die Mock-Datenquelle
/// wirft dieselbe Exception, damit UI-Code backend-unabhängig bleibt.
class VerificationRequiredException implements Exception {
  const VerificationRequiredException();
}

/// belong ist ab 18: das Onboarding kann nicht ohne Altersbestätigung
/// abgeschlossen werden (serverseitig über die Database Rules erzwungen,
/// die Mock-Datenquelle spiegelt das Verhalten).
class AgeConfirmationRequiredException implements Exception {
  const AgeConfirmationRequiredException();
}
