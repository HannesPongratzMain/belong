import 'access_level.dart';
import 'json_utils.dart';

/// Exakter Treffpunkt einer Aktivität — serverseitig unter
/// `activities/$id/precise` ausgelagert und nur für Teilnehmer:innen lesbar
/// (siehe `firebase/database.rules.json`). `lat`/`lon` sind für eine
/// spätere Karten-Ansicht vorgesehen, aktuell zeigt die App nur [address].
class PreciseLocation {
  const PreciseLocation({required this.address, this.lat, this.lon});

  final String address;
  final double? lat;
  final double? lon;

  factory PreciseLocation.fromJson(Map<String, dynamic> json) =>
      PreciseLocation(
        address: json['address'] as String,
        lat: (json['lat'] as num?)?.toDouble(),
        lon: (json['lon'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {'address': address, 'lat': lat, 'lon': lon};
}

/// Kategorien aus dem Design (Feed-Chips & CategoryPicker).
enum ActivityCategory {
  draussen('Draußen'),
  tanzen('Tanzen'),
  spiele('Spiele'),
  musik('Musik'),
  essen('Essen'),
  kaffee('Kaffee');

  const ActivityCategory(this.label);

  final String label;

  static ActivityCategory fromJson(String value) =>
      ActivityCategory.values.firstWhere(
        (category) => category.name == value,
        orElse: () => ActivityCategory.draussen,
      );

  String toJson() => name;
}

/// Eine konkrete Aktivität — das zentrale Objekt der App.
///
/// Es gibt bewusst keine Likes, Follower oder Rankings; sichtbar ist nur,
/// was für die Entscheidung „Bin ich dabei?" nötig ist.
class Activity {
  const Activity({
    required this.id,
    required this.title,
    required this.category,
    required this.startsAt,
    required this.participantCount,
    this.description,
    this.precise,
    this.isOnline = false,
    this.area,
    this.capacity,
    this.hostId,
    this.photoHint,
    this.isCancelled = false,
  });

  final String id;
  final String title;
  final String? description;
  final ActivityCategory category;

  /// Exakter Treffpunkt — `null`, wenn [isOnline] **oder** wenn die
  /// aktuelle Nutzer:in (noch) nicht beigetreten ist: der Server hält das
  /// Feld dann serverseitig zurück (`activities/$id/precise`), es ist kein
  /// reines UI-Ausblenden.
  final PreciseLocation? precise;
  final bool isOnline;

  /// Stadtteil für den Orts-Filter (z. B. „Vorderer Westen").
  final String? area;

  final DateTime startsAt;

  /// Teilnehmerlimit; `null` = offen für alle.
  final int? capacity;
  final int participantCount;

  /// Nur die anonyme Host-Referenz, kein öffentliches Profil.
  final String? hostId;

  /// Beschreibung des (Platzhalter-)Fotos, z. B. „Laufgruppe von hinten".
  final String? photoHint;

  /// Vom Host abgesagt — verschwindet aus dem Feed, der Chat bleibt offen.
  final bool isCancelled;

  bool get isOpenForAll => capacity == null;

  int? get freeSpots =>
      capacity == null ? null : (capacity! - participantCount).clamp(0, capacity!);

  bool get isFull => freeSpots != null && freeSpots == 0;

  /// Ortstext für den jeweils erlaubten Detailgrad — vor Beitritt nur der
  /// Stadtteil, danach der exakte Treffpunkt (BEL-03-Sichtbarkeitsmatrix).
  /// Gleiche visuelle Darstellung in Feed/Detail, nur der Text ändert sich.
  String placeLabelFor(AccessLevel level) {
    if (isOnline) return 'Online';
    if (level == AccessLevel.joined && precise != null) return precise!.address;
    return area ?? '…';
  }

  Activity copyWith({int? participantCount, bool? isCancelled}) => Activity(
        id: id,
        title: title,
        description: description,
        category: category,
        precise: precise,
        isOnline: isOnline,
        area: area,
        startsAt: startsAt,
        capacity: capacity,
        participantCount: participantCount ?? this.participantCount,
        hostId: hostId,
        photoHint: photoHint,
        isCancelled: isCancelled ?? this.isCancelled,
      );

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        category: ActivityCategory.fromJson(json['category'] as String),
        precise: json['precise'] == null
            ? null
            : PreciseLocation.fromJson(
                (json['precise'] as Map).cast<String, dynamic>()),
        isOnline: json['isOnline'] as bool? ?? false,
        area: json['area'] as String?,
        startsAt: parseDateTime(json['startsAt']),
        capacity: (json['capacity'] as num?)?.toInt(),
        participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
        hostId: json['hostId'] as String?,
        photoHint: json['photoHint'] as String?,
        isCancelled: json['isCancelled'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.toJson(),
        'precise': precise?.toJson(),
        'isOnline': isOnline,
        'area': area,
        'startsAt': startsAt.toIso8601String(),
        'capacity': capacity,
        'participantCount': participantCount,
        'hostId': hostId,
        'photoHint': photoHint,
        'isCancelled': isCancelled,
      };
}

/// Eingabedaten aus dem „Starte was Kleines"-Formular.
class ActivityDraft {
  const ActivityDraft({
    required this.title,
    required this.category,
    required this.startsAt,
    this.description,
    this.locationName,
    this.isOnline = false,
    this.capacity,
  });

  final String title;
  final String? description;
  final ActivityCategory category;
  final String? locationName;
  final bool isOnline;
  final DateTime startsAt;
  final int? capacity;
}
