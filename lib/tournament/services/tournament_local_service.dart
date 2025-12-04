import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/tournament/tournament_data.dart';

/// Tournament Local Service
/// Handles saving and loading tournament data via SharedPreferences
class TournamentLocalService {
  static const String _key = 'tournament_data';

  /// Save tournament data to SharedPreferences
  static Future<bool> saveTournamentData(TournamentData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data.toJson());
      return await prefs.setString(_key, jsonString);
    } catch (e) {
      print('Error saving tournament data: $e');
      return false;
    }
  }

  /// Load tournament data from SharedPreferences
  static Future<TournamentData?> loadTournamentData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);

      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return TournamentData.fromJson(jsonMap);
    } catch (e) {
      print('Error loading tournament data: $e');
      return null;
    }
  }

  /// Delete tournament data from SharedPreferences
  static Future<bool> deleteTournamentData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_key);
    } catch (e) {
      print('Error deleting tournament data: $e');
      return false;
    }
  }

  /// Check if tournament data exists
  static Future<bool> hasTournamentData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_key);
    } catch (e) {
      print('Error checking tournament data: $e');
      return false;
    }
  }

  /// Load tournament data or return default
  static Future<TournamentData> loadOrCreateDefault() async {
    final data = await loadTournamentData();
    return data ?? TournamentData.defaultData();
  }
}

