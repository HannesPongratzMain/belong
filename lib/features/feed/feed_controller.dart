import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/models/activity.dart';
import '../../domain/models/feed_filter.dart';

/// Aktueller Filterzustand des Feeds.
final feedFilterProvider =
    NotifierProvider<FeedFilterController, FeedFilter>(FeedFilterController.new);

class FeedFilterController extends Notifier<FeedFilter> {
  @override
  FeedFilter build() => const FeedFilter();

  void setArea(String area) => state = state.copyWith(area: area);

  void setTimeRange(FeedTimeRange range) =>
      state = state.copyWith(timeRange: range);

  void setCategory(ActivityCategory? category) =>
      state = state.copyWith(category: () => category);

  void reset() => state = const FeedFilter();
}

/// Feed-Inhalt; lädt bei jeder Filteränderung neu.
///
/// `retry: null`-Rückgabe schaltet Riverpods automatische Wiederholung ab:
/// Fehler sollen als gestalteter Zustand sichtbar werden, mit explizitem
/// „Noch mal versuchen" — nicht im Hintergrund verschwinden.
final feedProvider = AsyncNotifierProvider<FeedController, List<Activity>>(
  FeedController.new,
  retry: (retryCount, error) => null,
);

class FeedController extends AsyncNotifier<List<Activity>> {
  /// Letzter erfolgreich geladener Stand — für „Zuletzt geladene anzeigen"
  /// im Fehler-Zustand.
  List<Activity>? _lastLoaded;

  @override
  Future<List<Activity>> build() async {
    final filter = ref.watch(feedFilterProvider);
    final activities =
        await ref.watch(activityRepositoryProvider).fetchActivities(filter);
    _lastLoaded = activities;
    return activities;
  }

  bool get hasCachedFeed => _lastLoaded != null;

  /// Zeigt nach einem Fehler den zuletzt geladenen Stand an.
  void showCachedFeed() {
    final cached = _lastLoaded;
    if (cached != null) state = AsyncData(cached);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
