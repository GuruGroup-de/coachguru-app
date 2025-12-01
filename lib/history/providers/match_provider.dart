import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/match_model.dart';

/// Match Provider
/// Manages match data with persistent storage using SharedPreferences
class MatchProvider extends ChangeNotifier {
  List<MatchModel> _matches = [];
  bool _isLoading = false;

  List<MatchModel> get matches => List.unmodifiable(_matches);
  bool get isLoading => _isLoading;

  /// Load matches from SharedPreferences
  Future<void> loadMatches() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('matches');
      if (raw == null || raw.isEmpty) {
        _matches = [];
        _isLoading = false;
        notifyListeners();
        return;
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        debugPrint('Error: matches data is not a list');
        _matches = [];
        _isLoading = false;
        notifyListeners();
        return;
      }
      _matches = decoded
          .where((item) => item is Map<String, dynamic>)
          .map((m) {
            try {
              return MatchModel.fromMap(m as Map<String, dynamic>);
            } catch (e) {
              debugPrint('Error parsing match: $e');
              return null;
            }
          })
          .whereType<MatchModel>()
          .toList();
      // Sort by date, newest first
      _matches.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      debugPrint('Error loading matches: $e');
      _matches = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save matches to SharedPreferences
  Future<void> saveMatches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _matches.map((m) => m.toMap()).toList();
      await prefs.setString('matches', jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving matches: $e');
    }
  }

  /// Add a new match
  void addMatch(MatchModel match) {
    _matches.add(match);
    _matches.sort((a, b) => b.date.compareTo(a.date));
    saveMatches();
    notifyListeners();
  }

  /// Remove a match
  void removeMatch(String matchId) {
    _matches.removeWhere((m) => m.id == matchId);
    saveMatches();
    notifyListeners();
  }

  /// Get match by ID
  MatchModel? getMatchById(String matchId) {
    try {
      return _matches.firstWhere((m) => m.id == matchId);
    } catch (e) {
      return null;
    }
  }
}
