import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'player_model.dart';
import 'match_performance.dart';

/// Player Provider
/// Manages player data with persistent storage using SharedPreferences
class PlayerProvider extends ChangeNotifier {
  List<PlayerModel> _players = [];
  bool _isLoading = false;

  /// Get all players
  List<PlayerModel> get players => List.unmodifiable(_players);

  /// Get loading state
  bool get isLoading => _isLoading;

  /// Load players from SharedPreferences
  Future<void> loadPlayers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final playersJson = prefs.getString('players_data');

      if (playersJson != null && playersJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(playersJson) as List<dynamic>;
        _players = decoded
            .map((item) => PlayerModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        _players = [];
      }
    } catch (e) {
      debugPrint('Error loading players: $e');
      _players = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save players to SharedPreferences
  Future<void> savePlayers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _players.map((player) => player.toJson()).toList();
      final playersJson = jsonEncode(jsonList);
      await prefs.setString('players_data', playersJson);
    } catch (e) {
      debugPrint('Error saving players: $e');
    }
  }

  /// Get player by ID
  PlayerModel? getPlayerById(String id) {
    try {
      return _players.firstWhere((player) => player.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add a new player
  void addPlayer(PlayerModel player) {
    // Check if player with same ID already exists
    if (getPlayerById(player.id) != null) {
      debugPrint('Player with ID ${player.id} already exists');
      return;
    }

    _players.add(player);
    notifyListeners();
    savePlayers();
  }

  /// Update an existing player
  void updatePlayer(PlayerModel updated) {
    final index = _players.indexWhere((player) => player.id == updated.id);
    if (index != -1) {
      _players[index] = updated;
      notifyListeners();
      savePlayers();
    } else {
      debugPrint('Player with ID ${updated.id} not found for update');
    }
  }

  /// Add match performance to a player
  void addMatchPerformance(String playerId, MatchPerformance perf) {
    final player = getPlayerById(playerId);
    if (player != null) {
      final updatedHistory = List<MatchPerformance>.from(player.matchHistory)
        ..add(perf);
      final updatedPlayer = PlayerModel(
        id: player.id,
        name: player.name,
        birthYear: player.birthYear,
        position: player.position,
        strongFoot: player.strongFoot,
        photoPath: player.photoPath,
        goals: player.goals + perf.goals,
        assists: player.assists + perf.assists,
        matchHistory: updatedHistory,
        scoutingNotes: player.scoutingNotes,
      );
      updatePlayer(updatedPlayer);
    } else {
      debugPrint('Player with ID $playerId not found');
    }
  }

  /// Add scouting note to a player
  void addScoutingNote(String id, String note) {
    final player = getPlayerById(id);
    if (player != null) {
      final updatedNotes = List<String>.from(player.scoutingNotes)..add(note);
      final updatedPlayer = PlayerModel(
        id: player.id,
        name: player.name,
        birthYear: player.birthYear,
        position: player.position,
        strongFoot: player.strongFoot,
        photoPath: player.photoPath,
        goals: player.goals,
        assists: player.assists,
        matchHistory: player.matchHistory,
        scoutingNotes: updatedNotes,
      );
      updatePlayer(updatedPlayer);
    } else {
      debugPrint('Player with ID $id not found');
    }
  }

  /// Update player photo path
  void updatePlayerPhoto(String id, String path) {
    final player = getPlayerById(id);
    if (player != null) {
      final updatedPlayer = player.copyWith(photoPath: path);
      updatePlayer(updatedPlayer);
    } else {
      debugPrint('Player with ID $id not found');
    }
  }

  /// Remove a player
  void removePlayer(String id) {
    final index = _players.indexWhere((player) => player.id == id);
    if (index != -1) {
      _players.removeAt(index);
      notifyListeners();
      savePlayers();
    } else {
      debugPrint('Player with ID $id not found for removal');
    }
  }

  /// Delete a player (alias for removePlayer)
  @Deprecated('Use removePlayer instead')
  void deletePlayer(String id) => removePlayer(id);

  /// Get players by position
  List<PlayerModel> getPlayersByPosition(String position) {
    return _players.where((player) => player.position == position).toList();
  }

  /// Get players sorted by goals
  List<PlayerModel> getPlayersSortedByGoals() {
    final sorted = List<PlayerModel>.from(_players);
    sorted.sort((a, b) => b.goals.compareTo(a.goals));
    return sorted;
  }

  /// Get players sorted by assists
  List<PlayerModel> getPlayersSortedByAssists() {
    final sorted = List<PlayerModel>.from(_players);
    sorted.sort((a, b) => b.assists.compareTo(a.assists));
    return sorted;
  }
}
