/// Tolerantes Parsen von Zeitstempeln aus externen Datenquellen:
/// akzeptiert ISO-8601-Strings und Epoch-Millisekunden; UTC-Zeiten
/// („…Z") werden für die Anzeige in Ortszeit umgerechnet.
DateTime parseDateTime(dynamic value) {
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  return DateTime.parse(value as String).toLocal();
}
