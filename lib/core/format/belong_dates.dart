/// Deutsche Kurzformate für Aktivitätszeiten — bewusst ohne `intl`,
/// der Prototyp braucht nur diese Handvoll Formate.
abstract final class BelongDates {
  static const _weekdaysShort = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
  static const _months = [
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember',
  ];

  static String time(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  static String weekday(DateTime dt) => _weekdaysShort[dt.weekday - 1];

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// „Heute · 18:00", „Morgen · 19:30", sonst „Sa 10:00".
  static String badge(DateTime dt, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    if (_sameDay(dt, reference)) return 'Heute · ${time(dt)}';
    if (_sameDay(dt, reference.add(const Duration(days: 1)))) {
      return 'Morgen · ${time(dt)}';
    }
    return '${weekday(dt)} ${time(dt)}';
  }

  /// „Fr, 4. Juli" für den Tag-Picker.
  static String dayLong(DateTime dt, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    if (_sameDay(dt, reference)) return 'Heute';
    if (_sameDay(dt, reference.add(const Duration(days: 1)))) return 'Morgen';
    return '${weekday(dt)}, ${dt.day}. ${_months[dt.month - 1]}';
  }
}
