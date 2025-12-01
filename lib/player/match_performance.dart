/// Match Performance Model
/// Represents a player's performance in a single match
class MatchPerformance {
  final DateTime date;
  final int minutes;
  final int goals;
  final int assists;
  final String note;

  MatchPerformance({
    required this.date,
    required this.minutes,
    required this.goals,
    required this.assists,
    required this.note,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'minutes': minutes,
      'goals': goals,
      'assists': assists,
      'note': note,
    };
  }

  /// Create from JSON
  factory MatchPerformance.fromJson(Map<String, dynamic> json) {
    return MatchPerformance(
      date: DateTime.parse(json['date'] as String),
      minutes: json['minutes'] as int,
      goals: json['goals'] as int,
      assists: json['assists'] as int,
      note: json['note'] as String,
    );
  }
}
