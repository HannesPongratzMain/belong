import 'package:flutter/widgets.dart';

/// Farb-Tokens aus dem Design-Handoff (`design_handoff_belong_flutter/README.md`).
///
/// Verbindliche Rollen:
/// - Koralle ist die **einzige** Aktionsfarbe — genau ein Primär-Button pro Screen.
/// - Beere ist reiner Akzent (Funke, einzelne Chips, Fehler-Rahmen), nie Fläche.
/// - Grundton ist Creme; App-Header sind Creme, nicht farbig gefüllt.
abstract final class BelongColors {
  // Grundflächen
  static const cream = Color(0xFFF1E8DA); // App-Grundton
  static const surface = Color(0xFFFCF8F2); // Screen-/Listen-Hintergrund
  static const card = Color(0xFFFFFFFF); // Karten
  static const header = Color(0xFFEFE6D8); // App-Header-Fläche
  static const headerBlob = Color(0xFFF6D3C7); // Deko-Blob im Header, Opacity 0.8

  // Text (warme Tinte — nie kühles Grau)
  static const ink = Color(0xFF2F2A25); // Primärtext
  static const inkSoft = Color(0xFF4A423B); // Labels
  static const muted = Color(0xFF6E6358); // Sekundärtext (AA auf Creme)
  static const placeholder = Color(0xFFB9A08D);

  // Koralle — DIE einzige Aktionsfarbe
  static const coral = Color(0xFFF25A43); // Buttons, aktive Chips, Radio
  static const coralDeep = Color(0xFFA23A20); // Coral-Text auf hellen Flächen
  static const coralTint = Color(0xFFFBE7DC); // Flächen/Chips
  static const coralWash = Color(0xFFFDF2EB);

  // Wortmarke
  static const wordmark = Color(0xFFFF6F4D); // „BELONG" in Luckiest Guy
  static const wordmarkShadow = Color(0xD92A1E1A); // rgba(42,30,26,0.85)

  // Beere — reiner Akzent, nie Grundfläche
  static const berry = Color(0xFFD62F6B); // Funke, kleine Details, Fehler-Rahmen
  static const berryDeep = Color(0xFFA81552); // Text auf berryTint
  static const berryTint = Color(0xFFF8DCE7); // Chips (z. B. „Tanzen")

  // Stütztöne
  static const amberTint = Color(0xFFF4E6CC); // Chips (z. B. „Draußen")
  static const amberDeep = Color(0xFF8A5A22); // Text auf amberTint
  static const sunflower = Color(0xFFE7B22E); // Badges („Heute · 18:00"), Profil-Header
  static const forest = Color(0xFF22401E); // Text auf sunflower
  static const sage = Color(0xFF2C6E4C); // Erfolg
  static const sageTint = Color(0xFFE2ECE4);
  static const error = Color(0xFF9C2A22); // semantischer Fehler (Text auf Weiß)

  // Linien & neutrale Chips
  static const hairline = Color(0xFFEBDECB);
  static const border = Color(0xFFEEE4D6);
  static const borderIdle = Color(0xFFDFD2BB); // inaktive Radio-Ringe
  static const chipNeutral = Color(0xFFF1E6D5); // Filter-Dropdown-Pills

  // Scrim für Sheets (rgba(42,30,26,0.32))
  static const scrim = Color(0x522A1E1A);

  // Warmer Schatten-Grundton rgba(74,50,34,x)
  static const shadowBase = Color(0xFF4A3222);
}
