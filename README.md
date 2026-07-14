# belong

**belong** verbindet Menschen über konkrete Aktivitäten statt über Profile —
anonym, niedrigschwellig, ohne Likes, Follower oder Ranking.
Flutter-App mit Firebase-Backend, entstanden im Modul „Entwicklung eines
digitalen Produktes – UI, UX und sichere Mensch-Technik-Interaktion".

## Starten

```bash
flutter pub get
flutter run                  # Gerät/Emulator auswählen
flutter run -d chrome        # im Browser
flutter build apk --release  # Android-APK (build/app/outputs/flutter-apk/)
```

Tests & Analyse: `flutter test` · `flutter analyze`

Die App verbindet sich beim Start mit der Live-Datenbank (anonyme
Anmeldung, kein Account nötig) und zeigt echte Aktivitäten aus Kassel.

**Demo-Tipps:**
- Auf zwei Geräten gleichzeitig öffnen (z. B. Handy + Browser): Beitritte,
  Teilnehmerzahlen und Chat synchronisieren sich live.
- Long-Press auf die „Kassel"-Pill im Feed simuliert einen Netzwerkfehler
  (gestalteter Fehler-Zustand). Der Leer-Zustand erscheint z. B. mit
  Filter „Tanzen" + „Heute".
- Long-Press auf eine fremde Chat-Nachricht öffnet das Schutz-Sheet
  (Melden / Blockieren / Stummschalten).

## Funktionen

- **Onboarding** — anonymer Einstieg mit drei Sichtbarkeits-Stufen
  (ganz anonym / Spitzname / Spitzname + Interessen), ohne E-Mail
- **Altersgrenze 18+** — datensparsame Selbstbestätigung im Onboarding
  (nur das „Ja" wird gespeichert, kein Geburtsdatum); serverseitig über
  die Database Rules erzwungen, Bestandsprofile ohne Bestätigung landen
  in einem Age-Gate vor der App
- **Feed** — Aktivitäten entdecken, Filter (Stadtteil, Zeitraum, Kategorie),
  inkl. Lade- (Skeletons), Leer- und Fehler-Zustand
- **One-Click-Join** — Zustand sichtbar: beitreten / dabei / voll / verlassen
- **Aktivität erstellen** — Formular mit freundlicher Validierung und
  Erfolgs-Moment („Steht!")
- **Host-Werkzeuge** — Bearbeiten (gleiche Maske, vorbefüllt) und Absagen
  mit Rückfrage; beides erscheint als System-Notiz im Gruppenchat,
  Abgesagtes verschwindet aus dem Feed, der Chat bleibt offen
- **In-App-Erinnerung** — „in 2 h"-Badge im Chats-Tab und Hinweis im
  Detail, wenn eine Aktivität innerhalb der nächsten 12 Stunden startet
- **Gruppenchat** — erst nach dem Beitreten zugänglich (serverseitig
  erzwungen); Treffpunkt teilen (vorbefüllt aus der Aktivität, „Route"
  öffnet im Browser die Karte, sonst Zwischenablage); Melden, Blockieren
  und Stummschalten über das Schutz-Sheet
- **Profil** — minimal & anonym: Stufe jederzeit wechselbar, eigene
  Teilnahmen und gestartete Aktivitäten

## Architektur

```
lib/
├── app/            App-Shell (Tabs), RootGate (Onboarding ↔ App ↔ Fehler)
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
│   ├── firebase/      Produktiv-Implementierung: Realtime Database + Anonymous
│   │                  Auth über REST/SSE (Auth-Client, RTDB-Client, 4 Repos)
│   ├── mock/          Plan B: In-Memory-Implementierung mit simulierter
│   │                  Latenz und Streams (auch Basis der Widget-Tests)
│   └── providers.dart **Der eine Austauschpunkt** für die Datenschicht
└── features/       Feature-Module: onboarding, feed, create,
                    activity_detail, chat, chats, profile, participation
```

- **Schichtentrennung:** UI → Riverpod-Controller → Repository-Interface →
  Datenquelle. Die UI kennt nur Interfaces, nie die konkrete Quelle.
- **State Management:** Riverpod (`Notifier`/`AsyncNotifier`/`StreamProvider`).

## Backend: Firebase Realtime Database

Die App läuft gegen eine Firebase Realtime Database — angebunden über die
**REST-API mit Anonymous Auth** (`lib/data/firebase/`), bewusst ohne native
FlutterFire-Plugins: identisches Verhalten auf iOS, Android, Web und
Desktop, keine App-Registrierung, keine `google-services.json` nötig.
Live-Updates (Chat, Teilnehmerzahlen) laufen über das SSE-Streaming der
RTDB; Zähler werden über ETag-basierte bedingte Schreibzugriffe
konfliktsicher geändert.

- Der Web-API-Key steht in `lib/data/firebase/firebase_config.dart` und
  kann beim Bauen überschrieben werden:
  `flutter build apk --dart-define=BELONG_FIREBASE_API_KEY=...`
  (Der Key ist bei Firebase-Apps öffentlich; die Zugriffskontrolle leisten
  die Security Rules.)
- Datenstruktur: `/users`, `/activities`, `/participations`,
  `/activityParticipants` (Spiegel-Index für die Chat-Zugriffsregel),
  `/chats`, `/moderation` (reports/blocks/mutes).
- **Security Rules:** `firebase/database.rules.json` ist die Single Source
  of Truth im Repo. Änderungen dort werden **manuell** in die Firebase-
  Konsole (Realtime Database → Regeln) kopiert und veröffentlicht — die
  App selbst braucht dafür keinen neuen Build.

**Plan B (Mockdaten):** Die komplette Mock-Datenschicht bleibt im Projekt.
Umschalten über den `dataBackendProvider` in `lib/data/providers.dart` —
die Widget-Tests erzwingen so die Mocks. Ist kein API-Key hinterlegt,
fällt die App automatisch auf die Mocks zurück.

## Privacy & Sicherheit

- **Datensparsamkeit im Modell:** kein Klarname, keine E-Mail, kein Foto;
  Interessen werden nur bei der passenden Sichtbarkeits-Stufe gespeichert.
- **Serverseitig erzwungen (Security Rules, empirisch geprüft):** Profile
  sind nur für die eigene Sitzung lesbar; Chats nur für Teilnehmer:innen;
  Aktivitäten ändert nur der Host; Meldungen sind für Clients unlesbar
  (write-only); Teilnehmerzähler nur um ±1 änderbar; Chat-Nachrichten kann
  nur die Absender:in anlegen — überschreiben oder löschen kann sie danach
  niemand. `.validate`-Regeln begrenzen Textlängen (Spitzname 30, Titel 80,
  Beschreibung/Nachricht 500 Zeichen) und erlauben nur bekannte Kategorien
  und Sichtbarkeits-Stufen.
- **Anonyme Auth als bewusster Trade-off:** jeder kann ohne Hürde einsteigen
  (Produktprinzip); zusätzlicher Missbrauchsschutz käme in Produktion über
  App Check und serverseitige Moderation dazu.

**Bekannte Prototyp-Grenzen** (bewusst, siehe Ausblick): Blockieren filtert
aktuell nur die eigene Anzeige, Meldungen werden noch nicht ausgewertet,
der Feed lädt ungefiltert alle Aktivitäten (skaliert nicht), Stummschalten
hat ohne Push-Benachrichtigungen keine Wirkung.

## Ausblick

Nächste sinnvolle Schritte Richtung Veröffentlichung: serverseitige
Feed-Queries + Cloud Functions für Join/Moderation, echtes (serverseitiges)
Blockieren, App Check, echte Push-Benachrichtigungen (die In-App-Erinnerung
ersetzt noch keinen Ping bei geschlossener App), eigener Signing-Key sowie
das Rechtspaket (Datenschutzerklärung, Moderationsprozess, Altersgrenze).

## Design

Vorlagen und Tokens liegen in `lib/design_handoff_belong_flutter/`
(README dort beschreibt Screens, Palette und Typografie). Die drei Fonts
(Luckiest Guy, Hedvig Letters Serif, Hanken Grotesk) sind lokal in
`assets/fonts/` gebündelt — kein Runtime-Download, identisch auf allen
Plattformen (iOS, Android, Web, Desktop).
