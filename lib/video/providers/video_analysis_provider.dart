import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/video_analysis_model.dart';

/// Video Analysis Provider
/// Manages video analysis data with persistent storage
class VideoAnalysisProvider extends ChangeNotifier {
  String? videoPath;
  List<VideoMoment> moments = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  bool get hasVideo => videoPath != null;

  /// Set the current video path
  void setVideo(String path) {
    videoPath = path;
    notifyListeners();
  }

  /// Add a moment to the analysis
  void addMoment(VideoMoment moment) {
    moments.add(moment);
    // Sort moments by timestamp
    moments.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    notifyListeners();
    saveAnalysis();
  }

  /// Remove a moment from the analysis
  void removeMoment(VideoMoment moment) {
    moments.remove(moment);
    notifyListeners();
    saveAnalysis();
  }

  /// Update a moment
  void updateMoment(VideoMoment oldMoment, VideoMoment newMoment) {
    final index = moments.indexOf(oldMoment);
    if (index != -1) {
      moments[index] = newMoment;
      moments.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      notifyListeners();
      saveAnalysis();
    }
  }

  /// Load analysis from SharedPreferences
  Future<void> loadAnalysis(String videoId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final analysisJson = prefs.getString('video_analysis_$videoId');

      if (analysisJson != null) {
        final data = jsonDecode(analysisJson) as Map<String, dynamic>;
        videoPath = data['videoPath'] as String?;
        moments =
            (data['moments'] as List?)
                ?.map((m) => VideoMoment.fromMap(m as Map<String, dynamic>))
                .toList() ??
            [];
      }
    } catch (e) {
      debugPrint('Error loading video analysis: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save analysis to SharedPreferences
  Future<void> saveAnalysis() async {
    if (videoPath == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final videoId = videoPath!.split('/').last;
      final data = {
        'videoPath': videoPath,
        'moments': moments.map((m) => m.toMap()).toList(),
      };
      await prefs.setString('video_analysis_$videoId', jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving video analysis: $e');
    }
  }

  /// Reset all analysis data
  void reset() {
    videoPath = null;
    moments = [];
    notifyListeners();
  }

  /// Export analysis as JSON
  Map<String, dynamic> exportAnalysis() {
    return {
      'videoPath': videoPath,
      'moments': moments.map((m) => m.toMap()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }
}
