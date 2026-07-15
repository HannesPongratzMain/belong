import 'package:flutter/widgets.dart';

import 'belong_colors.dart';

/// Schatten-Tokens — dezente Elevation, keine farbigen Glows.
abstract final class BelongShadows {
  static Color _warm(double opacity) =>
      BelongColors.shadowBase.withValues(alpha: opacity);

  /// E1 Ruhe: flache Erhebung für Pills, Rows, ruhige Flächen.
  static List<BoxShadow> get e1 => [
    BoxShadow(color: _warm(0.05), offset: const Offset(0, 1), blurRadius: 2),
    BoxShadow(color: _warm(0.06), offset: const Offset(0, 7), blurRadius: 18),
  ];

  /// E2 Karte: ActivityCards, Auswahl-Karten.
  static List<BoxShadow> get e2 => [
    BoxShadow(color: _warm(0.05), offset: const Offset(0, 1), blurRadius: 2),
    BoxShadow(color: _warm(0.09), offset: const Offset(0, 12), blurRadius: 28),
  ];

  /// E3 Schwebend: Sheets, schwebende Elemente.
  static List<BoxShadow> get e3 => [
    BoxShadow(color: _warm(0.06), offset: const Offset(0, 2), blurRadius: 6),
    BoxShadow(color: _warm(0.14), offset: const Offset(0, 24), blurRadius: 50),
  ];

  /// Harter Wortmarken-Schatten (Offset ohne Blur) als Text-Shadow.
  static List<Shadow> get wordmark => const [
    Shadow(color: BelongColors.wordmarkShadow, offset: Offset(0, 2)),
  ];
}
