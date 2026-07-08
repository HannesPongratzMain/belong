import 'package:flutter/widgets.dart';

import 'belong_colors.dart';

/// Ein Font-Stack für alles: Inter (lokal gebündelt, siehe pubspec.yaml).
/// Hierarchie entsteht über Gewicht und Größe, nicht über Font-Wechsel.
abstract final class BelongFonts {
  static const sans = 'Inter';

  /// Alias für bestehende Aufrufstellen.
  static const body = sans;
}

/// Typo-Rollen. Größen/Gewichte sind final und werden nicht verstreut im
/// Code überschrieben — nur via `copyWith` für Farbe.
abstract final class BelongText {
  // Display / Headlines (Inter Bold, leicht negatives Tracking)
  static const displaySuccess = TextStyle(
    fontFamily: BelongFonts.sans,
    fontSize: 27,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: BelongColors.ink,
  );
  static const displayTitle = TextStyle(
    fontFamily: BelongFonts.sans,
    fontSize: 22,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: BelongColors.ink,
  );
  static const sheetTitle = TextStyle(
    fontFamily: BelongFonts.sans,
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: BelongColors.ink,
  );
  static const cardTitle = TextStyle(
    fontFamily: BelongFonts.sans,
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: BelongColors.ink,
  );

  // Body & UI
  static const body = TextStyle(
    fontFamily: BelongFonts.sans,
    fontSize: 15,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: BelongColors.ink,
  );
  static const bodySmall = TextStyle(
    fontFamily: BelongFonts.sans,
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: BelongColors.muted,
  );
  static const rowTitle = TextStyle(
    fontFamily: BelongFonts.sans,
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: BelongColors.ink,
  );
  static const meta = TextStyle(
    fontFamily: BelongFonts.sans,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: BelongColors.muted,
  );
  static const label = TextStyle(
    fontFamily: BelongFonts.sans,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: BelongColors.inkSoft,
  );
  static const sectionLabel = TextStyle(
    fontFamily: BelongFonts.sans,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: BelongColors.inkSoft,
  );
  static const button = TextStyle(
    fontFamily: BelongFonts.sans,
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );
  static const buttonSmall = TextStyle(
    fontFamily: BelongFonts.sans,
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );
  static const chip = TextStyle(
    fontFamily: BelongFonts.sans,
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );
  static const badge = TextStyle(
    fontFamily: BelongFonts.sans,
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );
  static const caption = TextStyle(
    fontFamily: BelongFonts.sans,
    fontSize: 10,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );
  static const input = TextStyle(
    fontFamily: BelongFonts.sans,
    fontSize: 15,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: BelongColors.ink,
  );
}
