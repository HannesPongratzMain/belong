# belong

**belong** verbindet Menschen über konkrete Aktivitäten statt über Profile —
anonym, niedrigschwellig, ohne Likes, Follower oder Ranking.
Funktionsfähiger Flutter-Prototyp für das Modul „Entwicklung eines digitalen
Produktes – UI, UX und sichere Mensch-Technik-Interaktion".

## Starten

```bash
flutter pub get
flutter run            # Gerät/Emulator auswählen
flutter run -d chrome  # oder im Browser
```

Tests & Analyse: `flutter test` · `flutter analyze`

**Demo-Tipp:** Long-Press auf die „Kassel"-Pill im Feed simuliert einen
Netzwerkfehler (Fehler-Zustand). Der Leer-Zustand erscheint z. B. mit
Filter „Tanzen" + „Heute".

## Was der Prototyp kann

- **Onboarding** — anonymer Einstieg mit drei Sichtbarkeits-Stufen
  (ganz anonym / Spitzname / Spitzname + Interessen), ohne E-Mail
- **Feed** — Aktivitäten entdecken, Filter (Stadtteil, Zeitraum, Kategorie),
  inkl. Lade- (Skeletons), Leer- und Fehler-Zustand
- **One-Click-Join** — Zustand sichtbar: beitreten / dabei / voll / verlassen
- **Aktivität erstellen** — Formular mit freundlicher Validierung und
  Erfolgs-Moment („Steht!")
- **Gruppenchat** — erst nach dem Beitreten sichtbar; Melden, Blockieren und
  Stummschalten über das Schutz-Sheet (Long-Press auf fremde Nachrichten)
- **Profil** — minimal & anonym: Stufe jederzeit wechselbar, eigene
  Teilnahmen und gestartete Aktivitäten

## Architektur

```
lib/
├── app/            App-Shell (Tabs), RootGate (Onboarding ↔ App)
├── core/
│   ├── theme/      Design-Tokens aus dem Handoff (Farben, Typo, Radien,
│   │               Schatten, Spacing) + zentrales Theme
│   ├── widgets/    Design-System-Komponenten (Wortmarke, Funke-Icon,
│   │               AppHeader mit gerissener Kante, Buttons, Chips, Sheets …)
│   └── format/     Datums-Kurzformate („Heute · 18:00")
├── domain/models/  Datenmodelle mit fromJson/toJson (Activity, UserProfile,
│                   ChatMessage, Participation, FeedFilter)
├── data/
│   ├── repositories/  Abstrakte Interfaces: ActivityRepository,
│   │                  AuthRepository, ChatRepository, ParticipationRepository
│   ├── mock/          Mock-Implementierungen mit simulierter Latenz und
│   │                  Streams (In-Memory-„Datenbank")
│   └── providers.dart **Der eine Austauschpunkt** für die Datenschicht
└── features/       Feature-Module: onboarding, feed, create,
                    activity_detail, chat, chats, profile, participation
```

- **Schichtentrennung:** UI → Riverpod-Controller → Repository-Interface →
  Datenquelle. Die UI kennt nur Interfaces, nie die konkrete Quelle.
- **State Management:** Riverpod (`Notifier`/`AsyncNotifier`/`StreamProvider`).

## Backend: Firebase Realtime Database

Die App läuft standardmäßig gegen die Firebase Realtime Database
(`lib/data/firebase/`) — angebunden über die **REST-API mit Anonymous
Auth**, bewusst ohne native FlutterFire-Plugins: das funktioniert identisch
auf iOS, Android, Web **und** Desktop und braucht keine App-Registrierung.

**Einrichten (einmalig):**
1. In der Firebase-Konsole *Authentication → Sign-in method → Anonym*
   aktivieren.
2. Web-API-Schlüssel (*Projekteinstellungen → Allgemein*) in
   `lib/data/firebase/firebase_config.dart` eintragen — oder beim Bauen
   mitgeben: `flutter run --dart-define=BELONG_FIREBASE_API_KEY=...`

**Plan B (Mockdaten):** Die komplette Mock-Datenschicht
(`lib/data/mock/`) bleibt im Projekt. Ist kein API-Key hinterlegt, fällt
die App automatisch auf die Mocks zurück; erzwingen lässt sich das über
den `dataBackendProvider` in `lib/data/providers.dart` (Tests machen genau
das). Die Umschaltung ist ein einziger Provider — UI und Controller bleiben
unangetastet.

## Privacy by Design

Die Kernidee spiegelt sich im Code: kein Klarname und keine E-Mail im
Datenmodell, Interessen werden nur bei der passenden Stufe überhaupt
gespeichert (`MockAuthRepository`), Chat-Streams verweigern den Zugriff ohne
Teilnahme (`ChatAccessDeniedException`), Blockieren filtert serverseitig
(im Mock) statt nur in der UI.

## Design

Vorlagen und Tokens liegen in `lib/design_handoff_belong_flutter/`
(README dort beschreibt Screens, Palette und Typografie). Die drei Fonts
(Luckiest Guy, Hedvig Letters Serif, Hanken Grotesk) sind lokal in
`assets/fonts/` gebündelt — kein Runtime-Download, identisch auf allen
Plattformen (iOS, Android, Web, Desktop).
