import 'json_utils.dart';

/// Umfrage in einem Gruppenchat — getrennt von [ChatMessage] gespeichert
/// (`/chats/{activityId}/polls/{pollId}`), weil Nachrichten nach dem Senden
/// unveränderlich bleiben müssen. Frage/Optionen/Modus sind nach dem
/// Anlegen ebenfalls unveränderlich; nur [votes] ändert sich (eigener
/// veränderbarer Pfad `polls/{pollId}/votes/{uid}`).
class Poll {
  const Poll({
    required this.id,
    required this.question,
    required this.options,
    required this.allowMultiple,
    required this.createdBy,
    required this.createdAt,
    this.votes = const {},
  });

  final String id;
  final String question;
  final List<String> options;
  final bool allowMultiple;
  final String createdBy;
  final DateTime createdAt;

  /// uid → gewählte Options-Indizes (Single: genau ein Eintrag).
  final Map<String, List<int>> votes;

  /// Eigene Stimme, falls schon abgestimmt.
  List<int>? votesOf(String uid) => votes[uid];

  /// Anzahl Stimmen je Option, gleiche Reihenfolge wie [options].
  List<int> get tally {
    final counts = List<int>.filled(options.length, 0);
    for (final selection in votes.values) {
      for (final index in selection) {
        if (index >= 0 && index < counts.length) counts[index]++;
      }
    }
    return counts;
  }

  /// Anzahl Personen, die abgestimmt haben (nicht: Anzahl Stimmen).
  int get voterCount => votes.length;

  Poll copyWith({Map<String, List<int>>? votes}) => Poll(
        id: id,
        question: question,
        options: options,
        allowMultiple: allowMultiple,
        createdBy: createdBy,
        createdAt: createdAt,
        votes: votes ?? this.votes,
      );

  /// [json] enthält die Poll-Felder **und** den verschachtelten `votes`-
  /// Kindpfad (bei RTDB-Watches liegen beide im selben Teilbaum).
  factory Poll.fromJson(Map<String, dynamic> json) => Poll(
        id: json['id'] as String,
        question: json['question'] as String,
        options: (json['options'] as List).cast<String>(),
        allowMultiple: json['allowMultiple'] as bool? ?? false,
        createdBy: json['createdBy'] as String,
        createdAt: parseDateTime(json['createdAt']),
        votes: {
          for (final entry
              in (json['votes'] as Map<String, dynamic>? ?? const {}).entries)
            entry.key: _decodeSelection(entry.value),
        },
      );

  /// Ohne `votes`/`id` — die Stimmen leben in einem eigenen, veränderbaren
  /// Pfad, die id ist der RTDB-Schlüssel (wie bei [Participation]/[Friend]).
  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'allowMultiple': allowMultiple,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
      };

  /// Wire-Format je Modus: Single ein bloßer Index, Multi ein Array
  /// eindeutiger Indizes (siehe Security Rules).
  static Object encodeSelection(List<int> selection, {required bool allowMultiple}) =>
      allowMultiple ? selection : selection.first;

  static List<int> _decodeSelection(dynamic value) {
    if (value is List) return value.map((v) => (v as num).toInt()).toList();
    if (value is num) return [value.toInt()];
    return const [];
  }
}
