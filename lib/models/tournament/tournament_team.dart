/// Tournament Team Model
/// Represents a team in the tournament
class TournamentTeam {
  final String name;
  final List<String> players; // Only MyTeam uses this, opponents keep empty list

  TournamentTeam({
    required this.name,
    required this.players,
  });

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'players': players,
    };
  }

  /// Create from JSON map
  factory TournamentTeam.fromJson(Map<String, dynamic> json) {
    return TournamentTeam(
      name: json['name'] as String? ?? '',
      players: (json['players'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  /// Create a copy with updated fields
  TournamentTeam copyWith({
    String? name,
    List<String>? players,
  }) {
    return TournamentTeam(
      name: name ?? this.name,
      players: players ?? this.players,
    );
  }

  @override
  String toString() {
    return 'TournamentTeam(name: $name, players: ${players.length})';
  }
}

