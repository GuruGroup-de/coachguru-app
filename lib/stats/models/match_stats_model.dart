/// Match Stats Model
/// Represents comprehensive statistics for a match
class MatchStatsModel {
  int shots;
  int shotsOnTarget;
  int goals;
  int assists;
  int passes;
  int successfulPasses;
  int duelsWon;
  int duelsLost;
  int possessionOur;
  int possessionOpponent;
  List<Map<String, dynamic>> events;
  // example: { "minute": 11, "type": "Shot", "player": "Viktor" }

  MatchStatsModel({
    this.shots = 0,
    this.shotsOnTarget = 0,
    this.goals = 0,
    this.assists = 0,
    this.passes = 0,
    this.successfulPasses = 0,
    this.duelsWon = 0,
    this.duelsLost = 0,
    this.possessionOur = 50,
    this.possessionOpponent = 50,
    this.events = const [],
  });

  Map<String, dynamic> toMap() => {
    'shots': shots,
    'shotsOnTarget': shotsOnTarget,
    'goals': goals,
    'assists': assists,
    'passes': passes,
    'successfulPasses': successfulPasses,
    'duelsWon': duelsWon,
    'duelsLost': duelsLost,
    'possessionOur': possessionOur,
    'possessionOpponent': possessionOpponent,
    'events': events,
  };

  factory MatchStatsModel.fromMap(Map<String, dynamic> map) => MatchStatsModel(
    shots: map['shots'] ?? 0,
    shotsOnTarget: map['shotsOnTarget'] ?? 0,
    goals: map['goals'] ?? 0,
    assists: map['assists'] ?? 0,
    passes: map['passes'] ?? 0,
    successfulPasses: map['successfulPasses'] ?? 0,
    duelsWon: map['duelsWon'] ?? 0,
    duelsLost: map['duelsLost'] ?? 0,
    possessionOur: map['possessionOur'] ?? 50,
    possessionOpponent: map['possessionOpponent'] ?? 50,
    events: List<Map<String, dynamic>>.from(map['events'] ?? []),
  );

  /// Calculate pass accuracy percentage
  double get passAccuracy {
    if (passes == 0) return 0.0;
    return (successfulPasses / passes) * 100;
  }

  /// Calculate duel win percentage
  double get duelWinRate {
    final total = duelsWon + duelsLost;
    if (total == 0) return 0.0;
    return (duelsWon / total) * 100;
  }

  /// Calculate shot accuracy percentage
  double get shotAccuracy {
    if (shots == 0) return 0.0;
    return (shotsOnTarget / shots) * 100;
  }
}
