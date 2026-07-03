import 'package:flutter/widgets.dart';

import 'belong_colors.dart';

/// Font-Familien aus dem Handoff (lokal gebündelt, siehe pubspec.yaml).
abstract final class BelongFonts {
  static const wordmark = 'Luckiest Guy'; // nur Wortmarke
  static const display = 'Hedvig Letters Serif'; // Headlines / Card-Titel
  static const body = 'Hanken Grotesk'; // Body & UI
}

/// Typo-Rollen aus dem Handoff. Größen/Gewichte sind final und werden
/// nicht verstreut im Code überschrieben — nur via `copyWith` für Farbe.
abstract final class BelongText {
  // Display / Headlines (Hedvig Letters Serif, immer Regular)
  static const displaySuccess = TextStyle(
    fontFamily: BelongFonts.display,
    fontSize: 32,
    height: 1.15,
    color: BelongColors.ink,
  );
  static const displayTitle = TextStyle(
    fontFamily: BelongFonts.display,
    fontSize: 24,
    height: 1.2,
    color: BelongColors.ink,
  );
  static const sheetTitle = TextStyle(
    fontFamily: BelongFonts.display,
    fontSize: 23,
    height: 1.2,
    color: BelongColors.ink,
  );
  static const cardTitle = TextStyle(
    fontFamily: BelongFonts.display,
    fontSize: 21,
    height: 1.25,
    color: BelongColors.ink,
  );

  // Body & UI (Hanken Grotesk)
  static const body = TextStyle(
    fontFamily: BelongFonts.body,
    fontSize: 15,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: BelongColors.ink,
  );
  static const bodySmall = TextStyle(
    fontFamily: BelongFonts.body,
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: BelongColors.muted,
  );
  static const rowTitle = TextStyle(
    fontFamily: BelongFonts.body,
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: BelongColors.ink,
  );
  static const meta = TextStyle(
    fontFamily: BelongFonts.body,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: BelongColors.muted,
  );
  static const label = TextStyle(
    fontFamily: BelongFonts.body,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: BelongColors.inkSoft,
  );
  static const sectionLabel = TextStyle(
    fontFamily: BelongFonts.body,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: BelongColors.inkSoft,
  );
  static const button = TextStyle(
    fontFamily: BelongFonts.body,
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );
  static const buttonSmall = TextStyle(
    fontFamily: BelongFonts.body,
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );
  static const chip = TextStyle(
    fontFamily: BelongFonts.body,
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );
  static const badge = TextStyle(
    fontFamily: BelongFonts.body,
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );
  static const caption = TextStyle(
    fontFamily: BelongFonts.body,
    fontSize: 10,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );
  static const input = TextStyle(
    fontFamily: BelongFonts.body,
    fontSize: 15,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: BelongColors.ink,
  );
}
