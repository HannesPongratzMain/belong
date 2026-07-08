import 'dart:async';
import 'dart:math';

import '../../domain/models/activity.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/participation.dart';
import '../../domain/models/user_profile.dart';

/// Gemeinsame In-Memory-„Datenbank" aller Mock-Repositories.
///
/// Simuliert Netzwerk-Latenz und Live-Updates (Streams), damit sich der
/// Prototyp wie eine echte Datenquelle verhält. Beim Anschluss eines
/// Backends fällt diese Klasse ersatzlos weg — die Repository-Interfaces
/// bleiben unverändert.
class MockDatabase {
  MockDatabase({this.latency = const Duration(milliseconds: 650), Random? random})
      : _random = random ?? Random() {
    activities = seedActivities(DateTime.now());
    messages = seedMessages(activities);
  }

  final Duration latency;
  final Random _random;

  /// ID der lokalen Nutzer:in (entsteht „on device", kein Account).
  static const currentUserId = 'me';

  UserProfile? profile;
  late final List<Activity> activities;
  late final Map<String, List<ChatMessage>> messages;
  final Map<String, Participation> participations = {};
  final Set<String> myActivityIds = {};
  final Set<String> mutedChats = {};
  final Set<String> blockedUserIds = {};
  final Set<String> reportedMessageIds = {};

  /// Demo-Schalter: lässt den nächsten Feed-Abruf fehlschlagen
  /// (Fehler-Zustand aus dem Design vorführbar machen).
  bool failNextFeedFetch = false;

  final joinedIdsChanges = StreamController<Set<String>>.broadcast();
  final activityChanges = StreamController<Activity>.broadcast();
  final messageChanges = StreamController<ChatMessage>.broadcast();

  Set<String> get joinedIds => participations.keys.toSet();

  /// Simulierte Netzwerk-Latenz mit leichtem Jitter
  /// (Tests setzen `latency: Duration.zero` und überspringen das Warten).
  Future<T> call<T>(T Function() body) async {
    if (latency > Duration.zero) {
      final jitter = _random.nextInt(300) - 100;
      await Future<void>.delayed(
          latency + Duration(milliseconds: jitter.clamp(0, 300)));
    }
    return body();
  }

  Activity requireActivity(String id) =>
      activities.firstWhere((activity) => activity.id == id);

  void replaceActivity(Activity updated) {
    final index = activities.indexWhere((activity) => activity.id == updated.id);
    activities[index] = updated;
    activityChanges.add(updated);
  }

  void addMessage(ChatMessage message) {
    messages.putIfAbsent(message.activityId, () => []).add(message);
    messageChanges.add(message);
  }

  String nextId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(9999)}';

  String randomNickname() => _nicknamePool[_random.nextInt(_nicknamePool.length)];

  static const _nicknamePool = [
    'stiller-fuchs',
    'flinke-otter',
    'leise-lerche',
    'mutige-meise',
    'wacher-wal',
    'kluge-kraehe',
    'sanfter-luchs',
    'heller-igel',
  ];

  /// Nächster Wochentag (1 = Mo … 7 = So) ab heute, inklusive heute.
  static DateTime _nextWeekday(DateTime now, int weekday, int hour, int minute) {
    var date = DateTime(now.year, now.month, now.day, hour, minute);
    while (date.weekday != weekday || date.isBefore(now)) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  /// Beispiel-Aktivitäten aus dem Design-Handoff, zeitlich relativ zu [now].
  static List<Activity> seedActivities(DateTime now) {
    final today18 = DateTime(now.year, now.month, now.day, 18);
    return [
      Activity(
        id: 'a-lauftreff',
        title: 'Lauftreff Karlsaue',
        description:
            'Lockere 5 km durch die Karlsaue — wir laufen im Gesprächstempo '
            'und warten an jeder Ecke. Null Leistungsdruck, versprochen.',
        category: ActivityCategory.draussen,
        precise: const PreciseLocation(address: 'Orangerie, Karlsaue'),
        area: 'Mitte',
        startsAt: today18.isBefore(now) ? today18.add(const Duration(days: 1)) : today18,
        participantCount: 12,
        hostId: 'u-karla',
        photoHint: 'Laufgruppe von hinten, Karlsaue',
      ),
      Activity(
        id: 'a-salsa',
        title: 'Salsa-Schnupperkurs',
        description:
            'Erste Schritte, keine Vorkenntnisse, keine Tanzpartner:in nötig. '
            'Danach gibt es Limo an der Bar.',
        category: ActivityCategory.tanzen,
        precise: const PreciseLocation(address: 'Tanzschule La Vida'),
        area: 'Vorderer Westen',
        startsAt: _nextWeekday(now, DateTime.wednesday, 19, 0),
        capacity: 12,
        participantCount: 8,
        hostId: 'u-mira',
        photoHint: 'Tanzschuhe auf Parkett',
      ),
      Activity(
        id: 'a-kanutour',
        title: 'Kanutour auf der Fulda',
        description:
            'Gemütliche Tour flussabwärts bis zur Schleuse. Boote sind '
            'reserviert, Schwimmwesten gibt es vor Ort.',
        category: ActivityCategory.draussen,
        precise: const PreciseLocation(address: 'Bootsverleih Ahoi'),
        area: 'Mitte',
        startsAt: _nextWeekday(now, DateTime.saturday, 10, 0),
        capacity: 8,
        participantCount: 6,
        hostId: 'u-jan',
        photoHint: 'Kanus von oben, Fulda',
      ),
      Activity(
        id: 'a-spieleabend',
        title: 'Spieleabend',
        description:
            'Von Azul bis Codenames — wir bringen Spiele mit, du dich. '
            'Der große Tisch hinten ist reserviert.',
        category: ActivityCategory.spiele,
        precise: const PreciseLocation(address: 'Café Buntes Haus'),
        area: 'Vorderer Westen',
        startsAt: _nextWeekday(now, DateTime.friday, 19, 30),
        participantCount: 5,
        hostId: 'u-lena',
        photoHint: 'Brettspiel-Detail, Hände',
      ),
      Activity(
        id: 'a-chorabend',
        title: 'Offener Chorabend',
        description:
            'Einfach vorbeikommen und mitsingen — Notenkenntnisse braucht '
            'hier niemand.',
        category: ActivityCategory.musik,
        precise: const PreciseLocation(address: 'Kulturhaus Dock 4'),
        area: 'Mitte',
        startsAt: _nextWeekday(now, DateTime.thursday, 18, 30),
        participantCount: 9,
        hostId: 'u-tom',
        photoHint: 'Chorproberaum, von hinten',
      ),
      Activity(
        id: 'a-kaffee',
        title: 'Kaffee & Kennenlernen',
        description:
            'Eine Stunde Kaffee mit neuen Leuten aus dem Viertel. '
            'Kommen, sitzen, quatschen — mehr ist es nicht.',
        category: ActivityCategory.kaffee,
        precise: const PreciseLocation(address: 'Rösterei Kaffeewerk'),
        area: 'Wehlheiden',
        startsAt: _nextWeekday(now, DateTime.sunday, 15, 0),
        capacity: 6,
        participantCount: 3,
        hostId: 'u-samu',
        photoHint: 'Zwei Tassen, Holztisch',
      ),
      Activity(
        id: 'a-online-spiele',
        title: 'Online-Spieleabend: Codenames',
        description:
            'Für alle, die heute nicht raus wollen: eine Runde Codenames '
            'im Sprachchat. Link kommt im Gruppenchat.',
        category: ActivityCategory.spiele,
        isOnline: true,
        startsAt: _nextWeekday(now, DateTime.tuesday, 20, 0),
        capacity: 10,
        participantCount: 4,
        hostId: 'u-noor',
        photoHint: 'Laptop mit Spielbrett',
      ),
    ];
  }

  /// Chat-Verläufe mit glaubwürdigen Spitznamen (Strings aus dem Handoff).
  static Map<String, List<ChatMessage>> seedMessages(List<Activity> activities) {
    final kanutour = activities.firstWhere((a) => a.id == 'a-kanutour');
    final kanuBase = kanutour.startsAt.subtract(const Duration(days: 2));
    final spieleabend = activities.firstWhere((a) => a.id == 'a-spieleabend');
    final spieleBase = spieleabend.startsAt.subtract(const Duration(days: 1));

    return {
      'a-kanutour': [
        ChatMessage(
          id: 'm-kanu-1',
          activityId: 'a-kanutour',
          senderId: 'u-flinke-otter',
          senderNickname: 'flinke-otter',
          text: 'Nimmt jemand ein zweites Paddel mit?',
          sentAt: kanuBase,
        ),
        ChatMessage(
          id: 'm-kanu-2',
          activityId: 'a-kanutour',
          senderId: 'u-jan',
          senderNickname: 'jan_orga',
          isOrganizer: true,
          text: 'Klar, hab zwei. Treffpunkt ist hier:',
          sentAt: kanuBase.add(const Duration(minutes: 4)),
        ),
        ChatMessage(
          id: 'm-kanu-3',
          activityId: 'a-kanutour',
          senderId: 'u-jan',
          senderNickname: 'jan_orga',
          isOrganizer: true,
          type: ChatMessageType.meetupPin,
          text: 'Treffpunkt',
          pin: const MeetupPin(
            placeName: 'Bootsverleih Ahoi',
            address: 'Auedamm 27b',
            timeLabel: 'Sa 10:00',
          ),
          sentAt: kanuBase.add(const Duration(minutes: 5)),
        ),
      ],
      'a-spieleabend': [
        ChatMessage(
          id: 'm-spiele-1',
          activityId: 'a-spieleabend',
          senderId: 'u-lena',
          senderNickname: 'cafe-lena',
          isOrganizer: true,
          text: 'Der große Tisch hinten ist ab 19 Uhr für uns reserviert.',
          sentAt: spieleBase,
        ),
        ChatMessage(
          id: 'm-spiele-2',
          activityId: 'a-spieleabend',
          senderId: 'u-wanda',
          senderNickname: 'wuerfel-wanda',
          text: 'Ich bringe Azul und Codenames mit!',
          sentAt: spieleBase.add(const Duration(minutes: 12)),
        ),
      ],
    };
  }
}
