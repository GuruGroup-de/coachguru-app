import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'history_model.dart';

/// Simple local storage for match history
class HistoryStorage {
  static const String _key = 'match_history';

  /// Load all match history from SharedPreferences
  static Future<List<MatchHistory>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => MatchHistory.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // Newest first
    } catch (e) {
      return [];
    }
  }

  /// Save match history to SharedPreferences
  static Future<void> saveHistory(List<MatchHistory> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = history.map((match) => match.toJson()).toList();
      await prefs.setString(_key, jsonEncode(jsonList));
    } catch (e) {
      // Silent fail
    }
  }
}
