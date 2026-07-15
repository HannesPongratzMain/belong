import 'package:flutter/widgets.dart';

/// Farb-Tokens — reduzierte Palette: Neutral + Koralle (Orange) + Sonnenblume (Gelb).
///
/// Verbindliche Rollen:
/// - Koralle ist die **einzige** Aktionsfarbe — genau ein Primär-Button pro Screen.
/// - Sonnenblume ist reiner Status-/Badge-Akzent (z. B. „in 2 h"), nie Fläche.
/// - Grundton ist Off-White; Karten setzen sich in reinem Weiß ab.
abstract final class BelongColors {
  // Grundflächen
  static const cream = Color(0xFFF2F1ED); // App-Grundton (neutrales Off-White)
  static const surface = Color(0xFFF8F7F4); // Screen-/Listen-Hintergrund
  static const card = Color(0xFFFFFFFF); // Karten
  static const header = Color(0xFFF2F1ED); // App-Header-Fläche

  // Text (2–3 neutrale Graustufen — Dunkelgrau statt Schwarz)
  static const ink = Color(0xFF2A2B2E); // Primärtext
  static const inkSoft = Color(0xFF48494C); // Labels
  static const muted = Color(0xFF66686C); // Sekundärtext (AA auf Off-White)
  static const placeholder = Color(0xFFA6A7A9);

  // Koralle — DIE einzige Aktionsfarbe
  static const coral = Color(0xFFF25A43); // Buttons, aktive Chips, Radio
  static const coralDeep = Color(0xFFA23A20); // Coral-Text auf hellen Flächen
  static const coralTint = Color(0xFFFBE7DC); // Flächen/Chips
  static const coralWash = Color(0xFFFDF2EB);

  // Wortmarke
  static const wordmark = Color(0xFFFF6F4D);
  static const wordmarkShadow = Color(0xD92A1E1A);
  static const berry = Color(0xFFD62F6B);

  // Sonnenblume (Gelb) — nur Badges/Status, nie Fläche
  static const amberTint = Color(0xFFF6EAC9); // Chips (z. B. „Draußen")
  static const amberDeep = Color(0xFF8A5A22); // Text auf amberTint
  static const sunflower = Color(0xFFE7B22E); // Badges („Heute · 18:00")
  static const forest = Color(0xFF22401E); // Text auf sunflower
  static const sage = Color(0xFF2C6E4C); // Erfolg
  static const sageTint = Color(0xFFE2ECE4);
  static const error = Color(0xFF9C2A22); // semantischer Fehler (Text auf Weiß)

  // Linien & neutrale Chips
  static const hairline = Color(0xFFEAE9E6);
  static const border = Color(0xFFECEBE8);
  static const borderIdle = Color(0xFFD8D7D3); // inaktive Radio-Ringe
  static const chipNeutral = Color(0xFFEFEEEB); // Filter-Dropdown-Pills

  // Scrim für Sheets (dunkles Neutral, 32 %)
  static const scrim = Color(0x52242529);

  // Schatten-Grundton (nahezu neutral, minimal warm)
  static const shadowBase = Color(0xFF3A3835);
}
