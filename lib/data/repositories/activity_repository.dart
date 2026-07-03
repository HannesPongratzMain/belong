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

  /// Aktivitäten, die die aktuelle Nutzer:in gestartet hat.
  Future<List<Activity>> myActivities();
}
