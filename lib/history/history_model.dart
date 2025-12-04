/// Simple Match History Model
class MatchHistory {
  final String id;
  final String opponent;
  final DateTime date;
  final int goalsFor;
  final int goalsAgainst;
  final List<String> scorers;
  final List<String> assists;

  MatchHistory({
    required this.id,
    required this.opponent,
    required this.date,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.scorers,
    required this.assists,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'opponent': opponent,
      'date': date.toIso8601String(),
      'goalsFor': goalsFor,
      'goalsAgainst': goalsAgainst,
      'scorers': scorers,
      'assists': assists,
    };
  }

  static MatchHistory fromJson(Map<String, dynamic> json) {
    return MatchHistory(
      id: json['id'] as String? ?? '',
      opponent: json['opponent'] as String? ?? 'Unknown',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      goalsFor: json['goalsFor'] as int? ?? 0,
      goalsAgainst: json['goalsAgainst'] as int? ?? 0,
      scorers: json['scorers'] != null
          ? List<String>.from(json['scorers'] as List)
          : [],
      assists: json['assists'] != null
          ? List<String>.from(json['assists'] as List)
          : [],
    );
  }

  String get score => '$goalsFor:$goalsAgainst';
}
