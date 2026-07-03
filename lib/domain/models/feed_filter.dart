import 'activity.dart';

/// Zeitraum-Filter des Feeds (Dropdown-Pill „Diese Woche").
enum FeedTimeRange {
  today('Heute'),
  thisWeek('Diese Woche'),
  all('Alles');

  const FeedTimeRange(this.label);

  final String label;
}

/// Filterzustand des Aktivitäten-Feeds.
class FeedFilter {
  const FeedFilter({
    this.area = 'Ganz Kassel',
    this.timeRange = FeedTimeRange.thisWeek,
    this.category,
  });

  /// Stadtteil, „Ganz Kassel" = kein Orts-Filter.
  final String area;
  final FeedTimeRange timeRange;

  /// `null` = Chip „Alle".
  final ActivityCategory? category;

  static const areas = [
    'Ganz Kassel',
    'Vorderer Westen',
    'Mitte',
    'Nord-Holland',
    'Rothenditmold',
    'Wehlheiden',
  ];

  FeedFilter copyWith({
    String? area,
    FeedTimeRange? timeRange,
    ActivityCategory? Function()? category,
  }) =>
      FeedFilter(
        area: area ?? this.area,
        timeRange: timeRange ?? this.timeRange,
        category: category == null ? this.category : category(),
      );

  /// „Ganz Kassel" filtert nicht nach Stadtteil.
  bool get filtersArea => area != areas.first;

  bool matches(Activity activity, {required DateTime now}) {
    if (category != null && activity.category != category) return false;
    // Online-Aktivitäten sind überall „vor Ort".
    if (filtersArea && !activity.isOnline && activity.area != area) {
      return false;
    }
    final endOfToday = DateTime(now.year, now.month, now.day + 1);
    switch (timeRange) {
      case FeedTimeRange.today:
        if (activity.startsAt.isAfter(endOfToday)) return false;
      case FeedTimeRange.thisWeek:
        if (activity.startsAt.isAfter(now.add(const Duration(days: 7)))) {
          return false;
        }
      case FeedTimeRange.all:
        break;
    }
    return true;
  }
}
