import 'package:flutter/foundation.dart';
import '../models/match_stats_model.dart';

/// Match Stats Provider
/// Manages match statistics with real-time updates
class MatchStatsProvider extends ChangeNotifier {
  MatchStatsModel stats = MatchStatsModel();

  /// Increment a specific stat field
  void increment(String field) {
    switch (field) {
      case 'shots':
        stats.shots++;
        break;
      case 'shotsOnTarget':
        stats.shotsOnTarget++;
        break;
      case 'goals':
        stats.goals++;
        break;
      case 'assists':
        stats.assists++;
        break;
      case 'passes':
        stats.passes++;
        break;
      case 'successfulPasses':
        stats.successfulPasses++;
        break;
      case 'duelsWon':
        stats.duelsWon++;
        break;
      case 'duelsLost':
        stats.duelsLost++;
        break;
    }
    notifyListeners();
  }

  /// Decrement a specific stat field
  void decrement(String field) {
    switch (field) {
      case 'shots':
        if (stats.shots > 0) stats.shots--;
        break;
      case 'shotsOnTarget':
        if (stats.shotsOnTarget > 0) stats.shotsOnTarget--;
        break;
      case 'goals':
        if (stats.goals > 0) stats.goals--;
        break;
      case 'assists':
        if (stats.assists > 0) stats.assists--;
        break;
      case 'passes':
        if (stats.passes > 0) stats.passes--;
        break;
      case 'successfulPasses':
        if (stats.successfulPasses > 0) stats.successfulPasses--;
        break;
      case 'duelsWon':
        if (stats.duelsWon > 0) stats.duelsWon--;
        break;
      case 'duelsLost':
        if (stats.duelsLost > 0) stats.duelsLost--;
        break;
    }
    notifyListeners();
  }

  /// Update possession percentages
  void updatePossession(int our, int opponent) {
    stats.possessionOur = our;
    stats.possessionOpponent = opponent;
    notifyListeners();
  }

  /// Add an event to the timeline
  void addEvent(int minute, String type, String player) {
    stats.events.add({'minute': minute, 'type': type, 'player': player});
    // Sort events by minute
    stats.events.sort(
      (a, b) => (a['minute'] as int).compareTo(b['minute'] as int),
    );
    notifyListeners();
  }

  /// Remove an event
  void removeEvent(int index) {
    if (index >= 0 && index < stats.events.length) {
      stats.events.removeAt(index);
      notifyListeners();
    }
  }

  /// Load stats from a map
  void loadStats(Map<String, dynamic>? statsMap) {
    if (statsMap != null) {
      stats = MatchStatsModel.fromMap(statsMap);
    } else {
      stats = MatchStatsModel();
    }
    notifyListeners();
  }

  /// Reset all stats
  void reset() {
    stats = MatchStatsModel();
    notifyListeners();
  }
}
