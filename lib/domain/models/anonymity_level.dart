/// Sichtbarkeits-Stufe der Nutzer:in — jederzeit änderbar, kein E-Mail-Zwang.
///
/// Datensparsamkeit ist Produktprinzip: mehr als Spitzname + optionale
/// Interessen wird nirgends erhoben.
enum AnonymityLevel {
  /// Vorgeschlagener Spitzname, keine Angaben.
  anonymous,

  /// Selbst gewählter Spitzname — sonst nichts.
  nickname,

  /// Spitzname + Interessen (hilft beim Finden), weiterhin ohne Foto.
  nicknameInterests;

  static AnonymityLevel fromJson(String value) =>
      AnonymityLevel.values.firstWhere(
        (level) => level.name == value,
        orElse: () => AnonymityLevel.anonymous,
      );

  String toJson() => name;

  String get label => switch (this) {
        AnonymityLevel.anonymous => 'Ganz anonym',
        AnonymityLevel.nickname => 'Spitzname',
        AnonymityLevel.nicknameInterests => 'Spitzname + Interessen',
      };
}
