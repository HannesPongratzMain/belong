import 'package:flutter_test/flutter_test.dart';

import 'package:belong/domain/models/access_level.dart';
import 'package:belong/domain/models/verification_level.dart';

void main() {
  group('AccessLevel.derive — BEL-03-Sichtbarkeitsmatrix', () {
    test('anonym/unverifiziert, nicht beigetreten → locked', () {
      expect(
        AccessLevel.derive(
            verificationLevel: VerificationLevel.none, hasAccess: false),
        AccessLevel.locked,
      );
    });

    test('verifiziert, nicht beigetreten → unlockedNotJoined', () {
      expect(
        AccessLevel.derive(
            verificationLevel: VerificationLevel.phone, hasAccess: false),
        AccessLevel.unlockedNotJoined,
      );
    });

    test('beigetreten → joined, unabhängig vom Verifizierungsstand', () {
      expect(
        AccessLevel.derive(
            verificationLevel: VerificationLevel.phone, hasAccess: true),
        AccessLevel.joined,
      );
      expect(
        AccessLevel.derive(
            verificationLevel: VerificationLevel.none, hasAccess: true),
        AccessLevel.joined,
      );
    });
  });
}
