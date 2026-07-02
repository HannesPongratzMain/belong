# Handoff: belong — Mobile App (Flutter)

## Overview
**belong** ist eine anonyme, aktivitätsbasierte App, die junge Erwachsene in Kassel offline zusammenbringt („Real Time statt Screen Time"). Kein Profilzwang, keine Selbstdarstellung: Nutzer:innen sehen reale Aktivitäten (Lauftreff, Spieleabend, Kanutour …), treten mit einem Tap bei und koordinieren sich im Gruppenchat — wahlweise ganz anonym, mit Spitznamen oder mit Foto.

Dieses Paket enthält alles, um die fünf Hauptscreens samt Zuständen in einem **Flutter-Projekt** umzusetzen.

## Über die Design-Dateien
Die HTML-Dateien in diesem Ordner sind **Design-Referenzen** (im Browser öffnen — `support.js` und `image-slot.js` müssen daneben liegen). Sie sind Prototypen, die Look & Verhalten zeigen — **kein Produktionscode**. Aufgabe: Diese Designs in Flutter mit den üblichen Mitteln nachbauen (Material 3 als Basis, eigene `ThemeData`, `google_fonts`).

- `belong Screens v9.dc.html` — **maßgebliche Screens**: alle 5 Screens + Zustände, finale Palette
- `belong Design Direction v5.dc.html` — Design-Direction: Prinzipien, Typo, Elevation, Fotografie, Tonalität
- `belong Palette Preview v9.dc.html` — Palette-Board mit Rollenzuweisung der Farben

## Fidelity
**High-fidelity.** Farben, Typografie, Abstände, Radien und Copy sind final und sollen pixelgenau übernommen werden. Die exakten Hex-Werte, Schriftgrößen und Radien stehen unten und in den HTML-Quellen (alle Styles inline, direkt ablesbar).

## Design Tokens

### Farben (Dart)
```dart
abstract class BelongColors {
  // Grundflächen
  static const cream       = Color(0xFFF1E8DA); // App-Grundton
  static const surface     = Color(0xFFFCF8F2); // Screen-/Listen-Hintergrund
  static const card        = Color(0xFFFFFFFF); // Karten
  static const header      = Color(0xFFEFE6D8); // App-Header-Fläche
  static const headerBlob  = Color(0xFFF6D3C7); // Deko-Blob im Header, Opacity 0.8

  // Text (warme Tinte — nie kühles Grau)
  static const ink         = Color(0xFF2F2A25); // Primärtext
  static const inkSoft     = Color(0xFF4A423B); // Labels
  static const muted       = Color(0xFF6E6358); // Sekundärtext (AA auf Creme)
  static const placeholder = Color(0xFFB9A08D);

  // Koralle — DIE einzige Aktionsfarbe
  static const coral       = Color(0xFFF25A43); // Buttons, aktive Chips, Radio
  static const coralDeep   = Color(0xFFA23A20); // Coral-Text auf hellen Flächen
  static const coralTint   = Color(0xFFFBE7DC); // Flächen/Chips
  static const coralWash   = Color(0xFFFDF2EB);

  // Wortmarke
  static const wordmark        = Color(0xFFFF6F4D); // „BELONG" in Luckiest Guy
  static const wordmarkShadow  = Color(0xD92A1E1A); // rgba(42,30,26,0.85), Offset (0,2–3), blur 0

  // Beere — reiner Akzent, nie Grundfläche
  static const berry       = Color(0xFFD62F6B); // Funke, kleine Details, Fehler-Rahmen
  static const berryDeep   = Color(0xFFA81552); // Text auf berryTint
  static const berryTint   = Color(0xFFF8DCE7); // Chips (z. B. „Tanzen")

  // Stütztöne
  static const amberTint   = Color(0xFFF4E6CC); // Chips (z. B. „Draußen")
  static const amberDeep   = Color(0xFF8A5A22); // Text auf amberTint
  static const sunflower   = Color(0xFFE7B22E); // Badges („Heute · 18:00"), Profil-Header
  static const forest      = Color(0xFF22401E); // Text auf sunflower
  static const sage        = Color(0xFF2C6E4C); // Erfolg
  static const sageTint    = Color(0xFFE2ECE4);
  static const error       = Color(0xFF9C2A22); // semantischer Fehler (Text auf Weiß)

  // Linien & neutrale Chips
  static const hairline    = Color(0xFFEBDECB);
  static const border      = Color(0xFFEEE4D6);
  static const borderIdle  = Color(0xFFDFD2BB); // inaktive Radio-Ringe
  static const chipNeutral = Color(0xFFF1E6D5); // Filter-Dropdown-Pills
}
```

**Rollen (verbindlich):**
- Koralle ist die **einzige** Aktionsfarbe — genau **ein** Primär-Button pro Screen.
- Beere ist Akzent (Logo-Funke, einzelne Chips, Fehler-Rahmen) — **niemals** Hintergrundfläche.
- Grundton ist Creme; App-Header sind Creme (`header`), **nicht** farbig gefüllt.
- Wortmarke: immer Orange `#FF6F4D` mit hartem dunklem Schatten auf Creme — nie weiß auf Farbe.

### Kontrast (WCAG)
- Tinte auf Creme 12:1 (AAA) · Muted auf Creme 4,8:1 (AA) · CoralDeep auf Creme 5,5:1 (AA)
- **Weiß auf Coral #F25A43 ≈ 3,3:1** — nur für große/fette Button-Labels (≥15 px, w600) einsetzen; kleiner Text auf Coral ist tabu.
- Sonnenblume trägt nur `forest`-Text; Text steht nie ungeschützt auf Fotos.

### Typografie (google_fonts)
| Rolle | Font | Größe/Gewicht |
|---|---|---|
| Wortmarke | `GoogleFonts.luckiestGuy` | 23–29 px, Buchstaben einzeln ±2–3° rotiert, harter Schatten (0,2–3) ohne Blur |
| Display / Headlines | `GoogleFonts.hedvigLettersSerif` | 21–24 px (Card-Titel), 23 px (Sheet-Titel), 32 px (Erfolg) |
| Body & UI | `GoogleFonts.hankenGrotesk` | Body 13–15/400–500 · Labels 12/700 · Buttons 15–16/600 · Captions 10–11/600–700 |

### Radien
Input/Feld 16 · Message-Bubble 18 (eigene: 18/18/6/18) · Row-Card 20 · Auswahl-Karte 22 · ActivityCard 24 · Screen-Innenfläche 32 · Sheet 34 (oben) · Phone-Rahmen 44 · Chips/Buttons Pill (999) · Avatare/Blobs organisch: `borderRadius` 46% 54% 60% 40% / 52% 44% 56% 48% (in Flutter: leicht asymmetrische `superellipse`/Custom-Clipper oder statisches SVG).

### Schatten (immer warm, nie grau)
- E1 Ruhe: `0 1px 2px rgba(74,50,34,0.05)` + `0 6–8px 16–20px rgba(74,50,34,0.05–0.08)`
- E2 Karte: `0 1px 2px rgba(74,50,34,0.05)` + `0 12px 28px rgba(74,50,34,0.09)`
- E3 Schwebend/Phone: `0 2px 6px rgba(74,50,34,0.06)` + `0 24px 50px rgba(74,50,34,0.14)`
- Primär-Button-Glow: `0 10px 24px rgba(242,90,67,0.3)`

### Spacing
4er-Basis: 4 · 8 · 12 · 16 · 24 · 32 · 40 · 64. Screen-Padding 16–18, Card-Innenabstand 16, Sektionen 64. Hit-Targets ≥ 44 px.

## Screens / Views

Alle Screens stecken in `belong Screens v9.dc.html`; jedes Mock trägt ein `data-screen-label`. Wiederkehrende Elemente: **AppHeader** (Creme `#EFE6D8`, zentrierte/linke Wortmarke, Blob oben rechts, „gerissene" Unterkante als flache Wellen-Kurve → `CustomPainter`), **TabBar** (4 Tabs: Entdecken, Starten, Chats, Du; aktiv = coralDeep, inaktiv = muted).

### 01 Onboarding · Anonymitäts-Stufe
- Header: Wortmarke zentriert, Serif-Titel „Schön, dass du da bist." (`ink`), Subline `muted`.
- **AnonymityLevelCard ×3** (weiß, Radius 22): „Ganz anonym" (ausgewählt: 2 px Coral-Rahmen, Radio gefüllt, Badge „GUT ZUM STARTEN" amberTint/amberDeep), „Spitzname", „Spitzname + Interessen". Avatar-Blobs 44 px organisch.
- TrustNote (Punkt + „Ohne E-Mail · jederzeit änderbar · nichts wird bewertet"), PrimaryButton „Los geht's", GhostButton „Was passiert mit meinen Daten?".

### 02 Aktivitäten-Feed (+ Laden / Leer / Fehler)
- Header: Wortmarke links, weiße „Kassel"-Pill rechts (Text coralDeep).
- FilterBar: 2 Dropdown-Pills (`chipNeutral`), darunter Kategorie-Chips — aktiv „Alle" = Coral/Weiß; „Tanzen" berryTint/berryDeep, „Draußen" amberTint/amberDeep, „Spiele" coralTint/coralDeep (alle gleichrangig).
- **ActivityCard** (featured): Foto 132 px mit warmem Overlay-Gradient, Sonnenblume-Badge rotiert +3°, gerissene Weiß-Kante unten, Kategorie-Chip, Serif-Titel 21, Meta `muted`, „12 dabei" + Sage-Badge „offen für alle", JoinButton.
- **ActivityRow ×4**: 56 px Foto-Thumb (Radius 16), Titel w700 14, Meta 12, Kategorie-Chip + Plätze rechts.
- Zustände: **Laden** = Skeletons (`chipNeutral`-Blöcke) + 3 Farbpunkte (wordmark/berry/sunflower) + „Wir schauen, was heute geht …"; **Leer** = Amber-Blob mit Funke-Icon, „Gerade noch ruhig hier.", Doodle-Pfeil (berryDeep), PrimaryButton „Aktivität starten"; **Fehler** = Berry-Blob mit „!", „Hat gerade nicht geklappt.", Retry.

### 03 Aktivität erstellen (+ Validierung / Erfolg)
- Bottom-Sheet-Optik: Grabber, Titel „Starte was Kleines", Close-Button.
- Felder: Titel, CategoryPicker (Chips), Ort (mit Pin-Icon), Tag/Uhrzeit-Grid, Kurzbeschreibung (optional), CapacityStepper (±, Wert w700). PrimaryButton „Aktivität teilen" + Hinweiszeile.
- **Validierung**: Banner berryTint („Fast geschafft — ein Feld fehlt noch."), Fehler-Feld mit 2 px Berry-Rahmen + Inline-Hinweis berryDeep. Freundlich, kein rotes Alarm-Design.
- **Erfolg**: Sonnenblume-Blob mit Funke, „Steht!" + Squiggle-Underline (`wordmark`-Orange, Custom-Painter), Bestätigungstext, „Zur Aktivität" + Ghost „Zurück zum Feed". Hintergrund-Blobs coralTint/berryTint.

### 04 Profil · minimal & anonym
- Identity-Header auf **Sonnenblume** `#E7B22E` (einzige farbige Kopffläche der App): weißer ?-Blob 76 px, Name Serif 24 `ink`, Pills „Ganz anonym" (weiß/coralDeep) + „ändern" (rgba-Tinte).
- AntiSocialNote: „Kein Foto nötig · keine Follower · nichts zu polieren".
- InterestChips, „Du bist dabei"-Rows (JoinedActivityRow), VisibilityRow (coralTint-Fläche, Schild-Icon, coralDeep-Text), TabBar („Du" aktiv).

### 05 Gruppenchat (+ Schutz-Sheet)
- ChatHeader weiß: Back, Titel + „6 dabei · Sa 10:00", **SafetyButton** „Schutz" (coralTint/coralDeep) sichtbar im Header.
- SystemNote-Pills zentriert. Fremde Bubbles: weiß, Border, Radius 18/18/18/6, Absender-Label berryDeep bzw. amberDeep + „ORGA"-Badge. Eigene: Coral, weißer Text, Radius 18/18/6/18, rechtsbündig.
- **MeetupPinCard**: Karten-Platzhalter 86 px, Coral-Pin, Ort + „Route"-Pill.
- Composer: Standort-Button, Eingabe-Pill, Coral-Senden-FAB 44 px.
- **SafetySheet** (Long-Press auf Nachricht): Scrim rgba(42,30,26,0.32), Sheet Radius 34 oben, Rows „Nachricht melden" / „Person blockieren" (berryDeep) / „Nur stummschalten", Abbrechen.

## Interactions & Behavior
- Genau **eine** Coral-Aktion pro Screen; Sekundär = neutral erhaben, Ghost = nur Text.
- Chips togglen Filter (aktiv = Coral gefüllt); Dropdown-Pills öffnen Auswahl-Sheets.
- Beitreten: JoinButton → Erfolgszustand „Du bist dabei." — Wir sagen dir kurz vorher Bescheid.
- Formular-Validierung inline & freundlich (nie schuldzuweisend), Banner + Feld-Rahmen.
- Loading = Skeletons (kein Spinner), Empty/Error = illustrierte Zustände mit genau einem CTA.
- Übergänge weich (200–300 ms, easeOut); Erfolgs-Funke darf kurz „poppen" (Scale 0.8→1, ~350 ms, overshoot).
- Tonalität der Copy: per „du", einladend, entlastend — exakte Strings aus den HTML-Dateien übernehmen.

## State Management
- `anonymityLevel` (enum: anonymous / nickname / nicknameInterests) — jederzeit änderbar, kein E-Mail-Zwang.
- Feed: `filters` (Ort, Zeitraum, Kategorie), `feedState` (loading / data / empty / error), Liste `Activity` (Titel, Kategorie, Ort, Zeit, Teilnehmerzahl, Kapazität, Foto).
- Create-Form: 6 Felder + Validierung (Titel Pflicht), `submitState` (idle / error / success).
- Chat: Nachrichten (Absender-Spitzname, ORGA-Flag, eigene/fremde), SafetySheet-Target, Block/Mute/Report-Aktionen.

## Assets
- Fonts: Luckiest Guy, Hedvig Letters Serif, Hanken Grotesk (alle via `google_fonts`).
- Icons: alle als einfache Stroke-SVGs (2.2–2.6 px, round caps) inline im HTML — in Flutter mit `flutter_svg` oder `CustomPaint` nachbauen. Der **Logo-Funke** ist absichtlich „gekritzelt" (4 leicht schiefe, gebogene Striche) — Pfade aus dem HTML kopieren.
- Fotos: Platzhalter (`<image-slot>`). Echte Fotos zeigen Aktivität statt Gesichter (von hinten / von oben / Detail), mit warmem Overlay.

## Screenshots
`screenshots/01–11` zeigen alle Screens in Reihenfolge: 01 Onboarding · 02 Feed · 03 Feed Laden · 04 Feed Leer · 05 Feed Fehler · 06 Erstellen · 07 Erstellen Validierung · 08 Erstellen Erfolg · 09 Profil · 10 Chat · 11 Chat Schutz-Sheet. Maßgeblich für exakte Werte bleibt das HTML.

## Files
- `belong Screens v9.dc.html` — alle Screens & Zustände (maßgeblich)
- `belong Design Direction v5.dc.html` — Prinzipien, Typo, Elevation, Fotografie, Tonalität, Kontrast-Tabelle
- `belong Palette Preview v9.dc.html` — Palette-Board mit Farb-Rollen
- `support.js`, `image-slot.js` — Laufzeit für die HTML-Referenzen (nicht portieren)
