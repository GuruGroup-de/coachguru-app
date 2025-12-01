import 'dart:convert';

/// Match Model
/// Represents a complete match record with statistics and timeline
class MatchModel {
  final String id;
  final String opponent;
  final String result; // "3:2"
  final DateTime date;
  final String type; // "League", "Friendly"
  final List<String> scorers;
  final int minutesPlayed;
  final int assists;
  final int goals;
  final List<Map<String, dynamic>> timeline;
  // example: { "minute": 23, "event": "Goal", "player": "Viktor" }
  final Map<String, dynamic>? stats; // Match statistics

  MatchModel({
    required this.id,
    required this.opponent,
    required this.result,
    required this.date,
    required this.type,
    required this.scorers,
    required this.minutesPlayed,
    required this.assists,
    required this.goals,
    required this.timeline,
    this.stats,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'opponent': opponent,
    'result': result,
    'date': date.toIso8601String(),
    'type': type,
    'scorers': scorers,
    'minutesPlayed': minutesPlayed,
    'assists': assists,
    'goals': goals,
    'timeline': timeline,
    'stats': stats,
  };

  factory MatchModel.fromMap(Map<String, dynamic> map) {
    try {
      return MatchModel(
        id: map['id'] as String? ?? '',
        opponent: map['opponent'] as String? ?? 'Unknown',
        result: map['result'] as String? ?? '0:0',
        date: map['date'] != null
            ? DateTime.parse(map['date'] as String)
            : DateTime.now(),
        type: map['type'] as String? ?? 'Friendly',
        scorers: map['scorers'] != null
            ? List<String>.from(map['scorers'] as List)
            : [],
        minutesPlayed: map['minutesPlayed'] as int? ?? 0,
        assists: map['assists'] as int? ?? 0,
        goals: map['goals'] as int? ?? 0,
        timeline: map['timeline'] != null
            ? List<Map<String, dynamic>>.from(map['timeline'] as List)
            : [],
        stats: map['stats'] as Map<String, dynamic>?,
      );
    } catch (e) {
      throw FormatException('Error parsing MatchModel: $e');
    }
  }
}
