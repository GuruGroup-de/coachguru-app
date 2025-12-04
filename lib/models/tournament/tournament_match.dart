/// Tournament Match Model
/// Represents a match in the tournament
class TournamentMatch {
  final String opponent; // Opponent name
  final String? result; // "3:1" (nullable)
  final List<String> scorers; // MyTeam scorers
  final List<String> assists; // MyTeam assists
  final DateTime date;

  TournamentMatch({
    required this.opponent,
    this.result,
    required this.scorers,
    required this.assists,
    required this.date,
  });

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'opponent': opponent,
      'result': result,
      'scorers': scorers,
      'assists': assists,
      'date': date.toIso8601String(),
    };
  }

  /// Create from JSON map
  factory TournamentMatch.fromJson(Map<String, dynamic> json) {
    return TournamentMatch(
      opponent: json['opponent'] as String? ?? '',
      result: json['result'] as String?,
      scorers: (json['scorers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      assists: (json['assists'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  TournamentMatch copyWith({
    String? opponent,
    String? result,
    List<String>? scorers,
    List<String>? assists,
    DateTime? date,
  }) {
    return TournamentMatch(
      opponent: opponent ?? this.opponent,
      result: result ?? this.result,
      scorers: scorers ?? this.scorers,
      assists: assists ?? this.assists,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'TournamentMatch(opponent: $opponent, result: $result, date: $date)';
  }
}

