import 'tournament_team.dart';
import 'tournament_match.dart';

/// Tournament Data Model
/// Contains all tournament information
class TournamentData {
  final TournamentTeam myTeam; // name = "MyTeam"
  final List<TournamentTeam> opponents; // unlimited opponents
  final List<TournamentMatch> matches; // auto-generated (N matches, where N = opponents.length)

  TournamentData({
    required this.myTeam,
    required this.opponents,
    required this.matches,
  });

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'myTeam': myTeam.toJson(),
      'opponents': opponents.map((team) => team.toJson()).toList(),
      'matches': matches.map((match) => match.toJson()).toList(),
    };
  }

  /// Create from JSON map
  factory TournamentData.fromJson(Map<String, dynamic> json) {
    return TournamentData(
      myTeam: TournamentTeam.fromJson(
        json['myTeam'] as Map<String, dynamic>? ?? {},
      ),
      opponents: (json['opponents'] as List<dynamic>?)
              ?.map((e) => TournamentTeam.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      matches: (json['matches'] as List<dynamic>?)
              ?.map((e) => TournamentMatch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Create a copy with updated fields
  TournamentData copyWith({
    TournamentTeam? myTeam,
    List<TournamentTeam>? opponents,
    List<TournamentMatch>? matches,
  }) {
    return TournamentData(
      myTeam: myTeam ?? this.myTeam,
      opponents: opponents ?? this.opponents,
      matches: matches ?? this.matches,
    );
  }

  /// Create default tournament data
  factory TournamentData.defaultData() {
    return TournamentData(
      myTeam: TournamentTeam(
        name: 'MyTeam',
        players: [],
      ),
      opponents: [], // Start with no opponents
      matches: [],
    );
  }

  @override
  String toString() {
    return 'TournamentData(myTeam: ${myTeam.name}, opponents: ${opponents.length}, matches: ${matches.length})';
  }
}

