import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_icon.dart';

/// Tactic Provider
/// Manages two teams (blue and red) with formation presets and persistence
class TacticProvider extends ChangeNotifier {
  List<PlayerIcon> _blueTeam = [];
  List<PlayerIcon> _redTeam = [];
  String _currentFormation = '4-3-3';
  bool _isBlueTeamActive = true; // Which team is currently being edited

  List<PlayerIcon> get blueTeam => List.unmodifiable(_blueTeam);
  List<PlayerIcon> get redTeam => List.unmodifiable(_redTeam);
  String get currentFormation => _currentFormation;
  bool get isBlueTeamActive => _isBlueTeamActive;

  /// Formation templates with positions (x, y) in pixels (normalized to 0-100%)
  final Map<String, List<Map<String, double>>> _formations = {
    '4-3-3': [
      {'x': 20.0, 'y': 10.0}, // GK
      {'x': 10.0, 'y': 30.0}, // LB
      {'x': 30.0, 'y': 30.0}, // CB1
      {'x': 50.0, 'y': 30.0}, // CB2
      {'x': 70.0, 'y': 30.0}, // RB
      {'x': 20.0, 'y': 50.0}, // CM1
      {'x': 50.0, 'y': 50.0}, // CM2
      {'x': 80.0, 'y': 50.0}, // CM3
      {'x': 20.0, 'y': 75.0}, // LW
      {'x': 50.0, 'y': 85.0}, // ST
      {'x': 80.0, 'y': 75.0}, // RW
    ],
    '4-4-2': [
      {'x': 20.0, 'y': 10.0}, // GK
      {'x': 10.0, 'y': 30.0}, // LB
      {'x': 30.0, 'y': 30.0}, // CB1
      {'x': 50.0, 'y': 30.0}, // CB2
      {'x': 70.0, 'y': 30.0}, // RB
      {'x': 15.0, 'y': 55.0}, // LM
      {'x': 40.0, 'y': 55.0}, // CM1
      {'x': 60.0, 'y': 55.0}, // CM2
      {'x': 85.0, 'y': 55.0}, // RM
      {'x': 35.0, 'y': 80.0}, // ST1
      {'x': 65.0, 'y': 80.0}, // ST2
    ],
    '3-5-2': [
      {'x': 20.0, 'y': 10.0}, // GK
      {'x': 20.0, 'y': 30.0}, // CB1
      {'x': 50.0, 'y': 30.0}, // CB2
      {'x': 80.0, 'y': 30.0}, // CB3
      {'x': 10.0, 'y': 55.0}, // LWB
      {'x': 30.0, 'y': 55.0}, // CM1
      {'x': 50.0, 'y': 55.0}, // CM2
      {'x': 70.0, 'y': 55.0}, // CM3
      {'x': 90.0, 'y': 55.0}, // RWB
      {'x': 40.0, 'y': 80.0}, // ST1
      {'x': 60.0, 'y': 80.0}, // ST2
    ],
    '2-3-1': [
      {'x': 20.0, 'y': 10.0}, // GK
      {'x': 30.0, 'y': 30.0}, // CB1
      {'x': 70.0, 'y': 30.0}, // CB2
      {'x': 20.0, 'y': 50.0}, // LM
      {'x': 50.0, 'y': 50.0}, // CM
      {'x': 80.0, 'y': 50.0}, // RM
      {'x': 50.0, 'y': 85.0}, // ST
    ],
  };

  /// Get available formation names
  List<String> get availableFormations => _formations.keys.toList();

  /// Initialize default players for a team
  void _initializeTeam(List<PlayerIcon> team, Color color, int startNumber) {
    team.clear();
    for (int i = 0; i < 11; i++) {
      team.add(
        PlayerIcon(
          id: '${color == Colors.blue ? 'blue' : 'red'}_${i + 1}',
          number: startNumber + i,
          color: color,
          position: Offset(50.0, 10.0 + (i * 8.0)),
        ),
      );
    }
  }

  /// Initialize both teams
  void initializeTeams() {
    _initializeTeam(_blueTeam, Colors.blue, 1);
    _initializeTeam(_redTeam, Colors.red, 1);
    notifyListeners();
  }

  /// Apply a formation template to the active team
  void applyFormation(String formationName) {
    final formation = _formations[formationName];
    if (formation == null) return;

    _currentFormation = formationName;
    final activeTeam = _isBlueTeamActive ? _blueTeam : _redTeam;

    if (activeTeam.length != formation.length) {
      // Reinitialize team if size doesn't match
      final color = _isBlueTeamActive ? Colors.blue : Colors.red;
      activeTeam.clear();
      for (int i = 0; i < formation.length; i++) {
        activeTeam.add(
          PlayerIcon(
            id: '${_isBlueTeamActive ? 'blue' : 'red'}_${i + 1}',
            number: i + 1,
            color: color,
            position: Offset(formation[i]['x']!, formation[i]['y']!),
          ),
        );
      }
    } else {
      // Update positions
      for (int i = 0; i < formation.length && i < activeTeam.length; i++) {
        activeTeam[i].position = Offset(formation[i]['x']!, formation[i]['y']!);
      }
    }

    notifyListeners();
    saveFormation();
  }

  /// Update player position
  void updatePlayerPosition(String id, Offset newPosition, bool isBlue) {
    try {
      final team = isBlue ? _blueTeam : _redTeam;
      final player = team.firstWhere((p) => p.id == id);
      // Clamp position to valid bounds (0-100%)
      final clampedX = newPosition.dx.clamp(0.0, 100.0);
      final clampedY = newPosition.dy.clamp(0.0, 100.0);
      player.position = Offset(clampedX, clampedY);
      notifyListeners();
    } catch (e) {
      print('[TacticProvider] Error updating player position: $e');
      print(
        '[TacticProvider] Player ID: $id, Team: ${isBlue ? 'blue' : 'red'}',
      );
    }
  }

  /// Switch active team
  void switchTeam() {
    _isBlueTeamActive = !_isBlueTeamActive;
    notifyListeners();
  }

  /// Save formation to SharedPreferences
  Future<void> saveFormation() async {
    try {
      // Validate teams before saving
      if (_blueTeam.isEmpty || _redTeam.isEmpty) {
        print('[TacticProvider] Cannot save: teams are empty');
        return;
      }

      if (_blueTeam.length != 11 || _redTeam.length != 11) {
        print(
          '[TacticProvider] Cannot save: invalid team sizes (blue: ${_blueTeam.length}, red: ${_redTeam.length})',
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final data = {
        'blue': _blueTeam.map((p) => p.toMap()).toList(),
        'red': _redTeam.map((p) => p.toMap()).toList(),
        'formation': _currentFormation,
        'activeTeam': _isBlueTeamActive ? 'blue' : 'red',
      };
      await prefs.setString('tactic_formation', jsonEncode(data));
      print(
        '[TacticProvider] Formation saved successfully: $_currentFormation',
      );
    } catch (e, stackTrace) {
      print('[TacticProvider] Error saving formation: $e');
      print('[TacticProvider] Stack trace: $stackTrace');
    }
  }

  /// Load formation from SharedPreferences
  Future<void> loadFormation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('tactic_formation');
      if (raw == null || raw.isEmpty) {
        print(
          '[TacticProvider] No saved formation found, initializing default 4-4-2',
        );
        applyFormation('4-4-2');
        return;
      }

      final data = jsonDecode(raw) as Map<String, dynamic>;

      // Validate and load blue team
      if (data['blue'] != null && data['blue'] is List) {
        final blueList = data['blue'] as List;
        if (blueList.length == 11) {
          _blueTeam = blueList
              .map((m) => PlayerIcon.fromMap(m as Map<String, dynamic>))
              .toList();
        } else {
          print(
            '[TacticProvider] Invalid blue team size: ${blueList.length}, expected 11. Regenerating.',
          );
          _blueTeam = [];
        }
      } else {
        print(
          '[TacticProvider] Blue team data is null or invalid. Regenerating.',
        );
        _blueTeam = [];
      }

      // Validate and load red team
      if (data['red'] != null && data['red'] is List) {
        final redList = data['red'] as List;
        if (redList.length == 11) {
          _redTeam = redList
              .map((m) => PlayerIcon.fromMap(m as Map<String, dynamic>))
              .toList();
        } else {
          print(
            '[TacticProvider] Invalid red team size: ${redList.length}, expected 11. Regenerating.',
          );
          _redTeam = [];
        }
      } else {
        print(
          '[TacticProvider] Red team data is null or invalid. Regenerating.',
        );
        _redTeam = [];
      }

      // If teams are empty or invalid, regenerate with default 4-4-2
      if (_blueTeam.isEmpty || _redTeam.isEmpty) {
        print(
          '[TacticProvider] Teams are empty, applying default 4-4-2 formation',
        );
        applyFormation('4-4-2');
        return;
      }

      _currentFormation = data['formation'] as String? ?? '4-4-2';
      _isBlueTeamActive = (data['activeTeam'] as String?) == 'blue';
      notifyListeners();
      print(
        '[TacticProvider] Formation loaded successfully: $_currentFormation',
      );
    } catch (e, stackTrace) {
      print('[TacticProvider] Error loading formation: $e');
      print('[TacticProvider] Stack trace: $stackTrace');
      print('[TacticProvider] Initializing default 4-4-2 formation');
      applyFormation('4-4-2');
    }
  }

  /// Reset formation to default
  void reset() {
    applyFormation('4-3-3');
  }
}
