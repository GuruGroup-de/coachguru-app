/// Scouting Note Model
/// Represents a scouting report for a specific player
class ScoutingNote {
  final String id;
  final String playerId;
  final DateTime date;
  final String strengths;
  final String weaknesses;
  final String potential;
  final String summary;

  ScoutingNote({
    required this.id,
    required this.playerId,
    required this.date,
    required this.strengths,
    required this.weaknesses,
    required this.potential,
    required this.summary,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playerId': playerId,
      'date': date.toIso8601String(),
      'strengths': strengths,
      'weaknesses': weaknesses,
      'potential': potential,
      'summary': summary,
    };
  }

  /// Create from JSON
  factory ScoutingNote.fromJson(Map<String, dynamic> json) {
    return ScoutingNote(
      id: json['id'] as String,
      playerId: json['playerId'] as String,
      date: DateTime.parse(json['date'] as String),
      strengths: json['strengths'] as String,
      weaknesses: json['weaknesses'] as String,
      potential: json['potential'] as String,
      summary: json['summary'] as String,
    );
  }
}
