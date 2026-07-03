import 'package:flutter/widgets.dart';

import 'belong_colors.dart';

/// Schatten-Tokens — immer warm (Basis rgba(74,50,34,x)), nie grau.
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

  /// Glow unter dem Primär-Button.
  static List<BoxShadow> get coralGlow => [
        BoxShadow(
          color: BelongColors.coral.withValues(alpha: 0.3),
          offset: const Offset(0, 10),
          blurRadius: 24,
        ),
      ];

  /// Sonnenblume-Badge („Heute · 18:00"): 0 4px 12px rgba(138,90,34,0.3).
  static List<BoxShadow> get sunflowerBadge => [
        BoxShadow(
          color: BelongColors.amberDeep.withValues(alpha: 0.3),
          offset: const Offset(0, 4),
          blurRadius: 12,
        ),
      ];

  /// Harter Wortmarken-Schatten (Offset ohne Blur) als Text-Shadow.
  static List<Shadow> get wordmark => const [
        Shadow(color: BelongColors.wordmarkShadow, offset: Offset(0, 2)),
      ];
}
