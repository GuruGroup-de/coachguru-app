import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TrainingAttendanceProvider extends ChangeNotifier {
  Map<String, Map<String, Map<String, String>>> _attendance = {};
  bool _isLoading = false;
  String _selectedSessionType = 'Training';

  Map<String, Map<String, Map<String, String>>> get attendance =>
      Map.unmodifiable(_attendance);

  bool get isLoading => _isLoading;

  String get selectedSessionType => _selectedSessionType;

  void setSelectedSessionType(String sessionType) {
    _selectedSessionType = sessionType;
    notifyListeners();
  }

  Future<void> loadAttendance() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final attendanceJson = prefs.getString('training_attendance');

      if (attendanceJson != null && attendanceJson.isNotEmpty) {
        final Map<String, dynamic> decoded =
            jsonDecode(attendanceJson) as Map<String, dynamic>;
        _attendance = decoded.map(
          (playerId, playerData) => MapEntry(
            playerId,
            (playerData as Map).map(
              (date, dateData) => MapEntry(
                date as String,
                Map<String, String>.from(dateData as Map),
              ),
            ),
          ),
        );
      } else {
        _attendance = {};
      }
    } catch (e) {
      _attendance = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveAttendance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final attendanceJson = jsonEncode(_attendance);
      await prefs.setString('training_attendance', attendanceJson);
    } catch (e) {
      // Silent fail
    }
  }

  void updateAttendance(
    String playerId,
    String date,
    String sessionType,
    String status,
  ) {
    if (!_attendance.containsKey(playerId)) {
      _attendance[playerId] = {};
    }
    if (!_attendance[playerId]!.containsKey(date)) {
      _attendance[playerId]![date] = {};
    }
    _attendance[playerId]![date]![sessionType] = status;
    notifyListeners();
    saveAttendance();
  }

  String? getAttendanceForPlayer(
    String playerId,
    String date,
    String sessionType,
  ) {
    return _attendance[playerId]?[date]?[sessionType];
  }

  double getAttendancePercentage(String playerId) {
    if (!_attendance.containsKey(playerId)) return 0.0;

    final List<String> allStatuses = [];
    for (final dateData in _attendance[playerId]!.values) {
      for (final status in dateData.values) {
        allStatuses.add(status);
      }
    }

    if (allStatuses.isEmpty) return 0.0;
    final yesCount = allStatuses.where((v) => v == 'Yes').length;
    return (yesCount / allStatuses.length) * 100;
  }
}
