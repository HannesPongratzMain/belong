import 'json_utils.dart';

/// Teilnahme der aktuellen Nutzer:in an einer Aktivität.
///
/// Bewusst schlank: es wird nur gespeichert, *dass* jemand dabei ist —
/// keine Aktivitätshistorie, kein Tracking.
class Participation {
  const Participation({required this.activityId, required this.joinedAt});

  final String activityId;
  final DateTime joinedAt;

  factory Participation.fromJson(Map<String, dynamic> json) => Participation(
        activityId: json['activityId'] as String,
        joinedAt: parseDateTime(json['joinedAt']),
      );

  Map<String, dynamic> toJson() => {
        'activityId': activityId,
        'joinedAt': joinedAt.toIso8601String(),
      };
}
