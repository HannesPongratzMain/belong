import '../../domain/models/activity.dart';
import '../../domain/models/feed_filter.dart';

/// Zugriff auf Aktivitäten. Die UI kennt nur dieses Interface;
/// ob dahinter Mockdaten, Firebase oder Supabase stehen, ist ihr egal.
abstract interface class ActivityRepository {
  /// Feed-Liste, bereits gefiltert und nach Startzeit sortiert.
  Future<List<Activity>> fetchActivities(FeedFilter filter);

  Future<Activity> activityById(String id);

  /// Live-Sicht auf eine Aktivität (Teilnehmerzahl ändert sich beim Join).
  Stream<Activity> watchActivity(String id);

  Future<Activity> createActivity(ActivityDraft draft);

  /// Host-Werkzeug: überarbeitet die Details einer eigenen Aktivität.
  /// Die Änderung erscheint als System-Notiz im Gruppenchat.
  Future<Activity> updateActivity(String id, ActivityDraft draft);

  /// Host-Werkzeug: sagt eine eigene Aktivität ab. Sie verschwindet aus
  /// dem Feed; der Chat bleibt für alle Beteiligten offen.
  Future<Activity> cancelActivity(String id);

  /// Aktivitäten, die die aktuelle Nutzer:in gestartet hat.
  Future<List<Activity>> myActivities();
}
