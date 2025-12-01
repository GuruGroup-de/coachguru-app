import 'match_performance.dart';

/// Player Model
/// Represents a complete player profile with statistics and history
class PlayerModel {
  final String id;
  final String name;
  final int? shirtNumber;
  final int birthYear;
  final String position;
  final String strongFoot;
  final String? photoPath;
  final int goals;
  final int assists;
  final List<MatchPerformance> matchHistory;
  final List<String> scoutingNotes;

  PlayerModel({
    required this.id,
    required this.name,
    this.shirtNumber,
    required this.birthYear,
    required this.position,
    required this.strongFoot,
    this.photoPath,
    this.goals = 0,
    this.assists = 0,
    List<MatchPerformance>? matchHistory,
    List<String>? scoutingNotes,
  }) : matchHistory = matchHistory ?? [],
       scoutingNotes = scoutingNotes ?? [];

  /// Calculate age from birth year
  int get age {
    final currentYear = DateTime.now().year;
    return currentYear - birthYear;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shirtNumber': shirtNumber,
      'birthYear': birthYear,
      'position': position,
      'strongFoot': strongFoot,
      'photoPath': photoPath,
      'goals': goals,
      'assists': assists,
      'matchHistory': matchHistory.map((match) => match.toJson()).toList(),
      'scoutingNotes': scoutingNotes,
    };
  }

  /// Create from JSON
  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      shirtNumber: json['shirtNumber'] as int?,
      birthYear: json['birthYear'] as int,
      position: json['position'] as String,
      strongFoot: json['strongFoot'] as String,
      photoPath: json['photoPath'] as String?,
      goals: json['goals'] as int? ?? 0,
      assists: json['assists'] as int? ?? 0,
      matchHistory:
          (json['matchHistory'] as List<dynamic>?)
              ?.map(
                (item) =>
                    MatchPerformance.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      scoutingNotes:
          (json['scoutingNotes'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          [],
    );
  }

  /// Create a copy with optional field updates
  PlayerModel copyWith({
    String? id,
    String? name,
    int? shirtNumber,
    int? birthYear,
    String? position,
    String? strongFoot,
    String? photoPath,
    int? goals,
    int? assists,
    List<MatchPerformance>? matchHistory,
    List<String>? scoutingNotes,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      shirtNumber: shirtNumber ?? this.shirtNumber,
      birthYear: birthYear ?? this.birthYear,
      position: position ?? this.position,
      strongFoot: strongFoot ?? this.strongFoot,
      photoPath: photoPath ?? this.photoPath,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      matchHistory: matchHistory ?? this.matchHistory,
      scoutingNotes: scoutingNotes ?? this.scoutingNotes,
    );
  }
}
