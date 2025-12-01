import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../models/scouting_note.dart';

/// Scouting Provider
/// Manages scouting notes with persistent storage using SharedPreferences
class ScoutingProvider extends ChangeNotifier {
  List<ScoutingNote> _notes = [];
  bool _isLoading = false;

  /// Get all notes
  List<ScoutingNote> get notes => List.unmodifiable(_notes);

  /// Get loading state
  bool get isLoading => _isLoading;

  /// Get notes for a specific player (latest first)
  List<ScoutingNote> notesForPlayer(String playerId) {
    return _notes.where((n) => n.playerId == playerId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Load notes from SharedPreferences
  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getString('scouting_notes_data');

      if (notesJson != null && notesJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(notesJson) as List<dynamic>;
        _notes = decoded
            .map((item) => ScoutingNote.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        _notes = [];
      }
    } catch (e) {
      debugPrint('Error loading scouting notes: $e');
      _notes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save notes to SharedPreferences
  Future<void> saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _notes.map((note) => note.toJson()).toList();
      final notesJson = jsonEncode(jsonList);
      await prefs.setString('scouting_notes_data', notesJson);
    } catch (e) {
      debugPrint('Error saving scouting notes: $e');
    }
  }

  /// Add a new scouting note
  void addScoutingNote({
    required String playerId,
    required String strengths,
    required String weaknesses,
    required String potential,
    required String summary,
  }) {
    final note = ScoutingNote(
      id: const Uuid().v4(),
      playerId: playerId,
      date: DateTime.now(),
      strengths: strengths,
      weaknesses: weaknesses,
      potential: potential,
      summary: summary,
    );

    _notes.add(note);
    notifyListeners();
    saveNotes();
  }

  /// Remove a scouting note
  void removeScoutingNote(String noteId) {
    _notes.removeWhere((note) => note.id == noteId);
    notifyListeners();
    saveNotes();
  }

  /// Get note by ID
  ScoutingNote? getNoteById(String noteId) {
    try {
      return _notes.firstWhere((note) => note.id == noteId);
    } catch (e) {
      return null;
    }
  }
}
