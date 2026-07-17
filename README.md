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
  (Melden / Blockieren / Stummschalten / Als Freund anfragen); bist du
  Host, kannst du darüber auch jede Nachricht (auch eigene) anpinnen.
- **Freundesystem demoen:** dafür den Mock-Modus erzwingen (siehe unten) —
  dort sind zwei eingehende Anfragen (`jan_orga`, `cafe-lena`) vorgeseedet
  und sofort unter „Du" → „FREUNDE" sichtbar (Annehmen/Ablehnen). Eine
  eigene Anfrage sendest du per Long-Press auf eine fremde Nachricht im
  Gruppenchat einer beigetretenen Aktivität.
- **Umfragen/Pins demoen:** im Gruppenchat einer selbst gehosteten
  Aktivität zeigt das Composer-Icon (Balkendiagramm, neben dem
  Treffpunkt-Pin) „Umfrage erstellen" — nur für den Host sichtbar. Stimmen
  aktualisieren sich live als Balken + Zahl. Angepinnt wird über das
  Schutz-Sheet (siehe oben); die angepinnte Nachricht erscheint als Banner
  oben im Chat, „Lösen" ist ebenfalls Host-only.
- **Melden/Auto-Hide demoen:** auf einer Aktivitätsdetailseite (nicht der
  eigenen) unten „Aktivität melden" tippen zeigt sofort die Bestätigung —
  ein zweites Mal in derselben Sitzung geht bewusst nicht (Client-Sperre).
  Die Schwelle selbst (3 Meldungen) lässt sich mit einer echten Nutzer:in
  über die UI kaum vorführen; am schnellsten testest du sie im Code, indem
  du vor dem Pumpen einer Aktivität `reportCount: 3` mitgibst (z. B.
  `db.replaceActivity(db.requireActivity('a-kanutour').copyWith(reportCount: 3))`
  auf einer `MockDatabase`-Instanz) — dann verschwindet sie aus dem Feed,
  direkt geöffnet erscheint „Wird geprüft".

**Mock-Modus erzwingen** (kein Firebase-Zugriff, Demo-Daten aus
`lib/data/mock/mock_database.dart`): jeder API-Key, der mit `<` beginnt,
gilt als „nicht konfiguriert" — die App fällt dann automatisch auf die
Mock-Datenschicht zurück (siehe [Plan B](#backend-firebase-realtime-database)).
Der Wert steht in `mock.env.json` (im Repo enthalten), damit `<`/`>` nicht
als Shell-Umleitung über `--dart-define=…` interpretiert werden — das
passiert unter Windows sowohl in PowerShell als auch in Git Bash, weil
`flutter.bat` die Zeichen intern nochmal an `cmd.exe` weiterreicht:

```bash
flutter run --dart-define-from-file=mock.env.json
```

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
- **Freundesystem (BEL-04, v1)** — verifizierte Mitglieder fragen sich
  gegenseitig per Long-Press auf eine Chat-Nachricht als Freund:in an;
  Annehmen/Ablehnen im Profil unter „FREUNDE". Bewusst ohne
  Kontaktabgleich/Telefonbuch-Upload — passt so zum Anonymitäts-Prinzip.
- **Safety-by-Design-Hinweise** — Gruppengröße („X von Y dabei") prominent
  im Aktivitätsdetail ohne Scrollen sichtbar; Sicherheitshinweis „Erstes
  Treffen? Öffentlicher Treffpunkt empfohlen." im Detail, beim
  Treffpunkt-Teilen und als Hilfetext im Erstellen-Formular
- **Umfragen & angepinnte Nachrichten im Chat** — Host erstellt Umfragen
  (2–6 Optionen, Einfach- oder Mehrfachauswahl) über ein Sheet; alle
  Teilnehmer:innen stimmen ab, Ergebnis live als Balken + Zahl (nie nur
  Farbe). Umfragen sind nach dem Anlegen unveränderlich und getrennt von
  Chat-Nachrichten gespeichert. Der Host kann außerdem eine Nachricht
  anpinnen (Banner oben im Chat, „Lösen" jederzeit möglich) — Nachrichten
  selbst bleiben dabei unverändert
- **Melden & Auto-Hide für Aktivitäten** — dezenter „Aktivität melden"-
  Link im Detail (pro Sitzung einmal auslösbar); ab drei Meldungen
  verschwindet eine Aktivität aus dem Feed, direkt geöffnet erscheint
  „Wird geprüft" statt der Details

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
  `/chats`, `/friendRequests`, `/friendships`, `/moderation`
  (reports/blocks/mutes).
- **Security Rules:** `firebase/database.rules.json` ist die Single Source
  of Truth im Repo. Änderungen dort werden **manuell** in die Firebase-
  Konsole (Realtime Database → Regeln) kopiert und veröffentlicht — die
  App selbst braucht dafür keinen neuen Build.
  ⚠️ Die Regeln für `/friendRequests`, `/friendships` (Freundesystem),
  `chats/*/polls`, `chats/*/meta` (Umfragen/Pins) sowie
  `activities/*/reportCount` (Melden/Auto-Hide) liegen aktuell nur lokal
  im Repo und sind **noch nicht** in die Firebase-Konsole übernommen — bis
  dahin funktionieren diese drei Features nur im Mock-Modus.

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
- **Moderiert werden Artefakte, nicht Identitäten** (bewusste
  Designentscheidung): gemeldet werden können Aktivitäten und Nachrichten,
  nicht Profile — es gibt kein Profil-Melden. Aus demselben Grund kann der
  Host Nachrichten weder löschen noch bearbeiten (Chat-Nachrichten bleiben
  unveränderlich, siehe oben) und niemanden aus dem Chat entfernen — ein
  Host-Kick wäre selbst ein Machtmittel, das der Host gegen genau die
  Personen einsetzen könnte, über die er Rechenschaft ablegen sollte.

**Bekannte Prototyp-Grenzen** (bewusst, siehe Ausblick): Blockieren filtert
aktuell nur die eigene Anzeige, der Feed lädt ungefiltert alle Aktivitäten
(skaliert nicht), Stummschalten hat ohne Push-Benachrichtigungen keine
Wirkung. Melde-Auswertung gibt es bislang nur für **Aktivitäten**: ab
`kReportHideThreshold` (Default 3, `lib/domain/models/activity.dart`)
verschwindet eine Aktivität aus dem Feed, direkt geöffnet erscheint „wird
geprüft" statt der Details. Chat-Nachrichten-Meldungen werden weiterhin
nicht ausgewertet (reiner Write-only-Bucket unter `moderation/reports`).
Der Melde-Zähler ist rein clientseitig aggregiert — kein serverseitiges
Nachzählen, keine Ent-Duplizierung pro Nutzer: dieselbe Person könnte
theoretisch mehrfach melden, und es gibt keinen Schutz vor koordiniertem
Wegmelden legitimer Aktivitäten (Brigading). Umfragen/Pins sind ebenfalls
bewusst minimal: eine angepinnte Nachricht genügt (kein Verlauf), Umfragen
lassen sich nach dem Anlegen nicht mehr bearbeiten oder löschen, und die
Ergebnis-Aggregation läuft rein im Client (kein serverseitiges Nachzählen/
keine serverseitige Deduplizierung bei Mehrfachauswahl).

## Ausblick

Nächste sinnvolle Schritte Richtung Veröffentlichung: serverseitige
Feed-Queries + Cloud Functions für Join/Moderation, echte (serverseitige)
Melde-Auswertung mit Ent-Duplizierung pro Nutzer (löst das Brigading-Risiko
oben), echtes (serverseitiges) Blockieren, App Check, echte
Push-Benachrichtigungen (die In-App-Erinnerung ersetzt noch keinen Ping bei
geschlossener App), eigener Signing-Key sowie das Rechtspaket
(Datenschutzerklärung, Moderationsprozess, Altersgrenze). Ein
Host-Kick/Teilnehmer-Entfernen bleibt bewusst offen — dafür bräuchte es
zunächst einen Eskalationsweg an ein unabhängiges Moderationsteam, sonst
ließe sich die Funktion gegen genau die Personen wenden, die sie schützen
soll. Naheliegende Erweiterung der Umfragen/Pins: ein Planungs-Assistent im
Chat (Checkliste/To-dos fürs Treffen, gemeinsame Abstimmung über mehrere
Fragen hinweg statt einer einzelnen Umfrage) — baut direkt auf den hier
gelegten `/polls`- und `/meta`-Pfaden auf.

## Design

Vorlagen und Tokens liegen in `lib/design_handoff_belong_flutter/`
(README dort beschreibt Screens, Palette und Typografie). Die drei Fonts
(Luckiest Guy, Hedvig Letters Serif, Hanken Grotesk) sind lokal in
`assets/fonts/` gebündelt — kein Runtime-Download, identisch auf allen
Plattformen (iOS, Android, Web, Desktop).
