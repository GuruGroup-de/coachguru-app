import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../theme/theme.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/share_button.dart';
import '../../models/tournament/tournament_data.dart';
import '../../models/tournament/tournament_match.dart';
import '../../models/tournament/tournament_team.dart';
import '../services/tournament_local_service.dart';

/// Tournament Schedule Screen
/// Displays tournament schedule
class TournamentScheduleScreen extends StatefulWidget {
  const TournamentScheduleScreen({Key? key}) : super(key: key);

  @override
  State<TournamentScheduleScreen> createState() => _TournamentScheduleScreenState();
}

class _TournamentScheduleScreenState extends State<TournamentScheduleScreen> {
  TournamentData? _tournamentData;
  bool _isLoading = true;
  List<MatchScheduleItem> _matchSchedules = [];

  @override
  void initState() {
    super.initState();
    _loadTournamentData();
  }

  Future<void> _loadTournamentData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await TournamentLocalService.loadOrCreateDefault();
      if (mounted) {
        setState(() {
          _tournamentData = data;
          _initializeMatchSchedules();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading tournament data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _initializeMatchSchedules() {
    if (_tournamentData == null) return;

    // Check if we need to generate matches
    if (_tournamentData!.opponents.isEmpty) {
      _matchSchedules = [];
      return;
    }

    // Generate or load match schedules
    if (_tournamentData!.matches.isEmpty) {
      // Generate matches dynamically based on number of opponents
      // totalMatches = opponents.length
      _matchSchedules = _tournamentData!.opponents.map((opponent) {
        return MatchScheduleItem(
          opponent: opponent.name,
          date: DateTime.now(),
          time: TimeOfDay.now(),
        );
      }).toList();
    } else {
      // Load existing matches
      _matchSchedules = _tournamentData!.matches.map((match) {
        final matchTime = match.date;
        return MatchScheduleItem(
          opponent: match.opponent,
          date: matchTime,
          time: TimeOfDay.fromDateTime(matchTime),
        );
      }).toList();
    }
  }

  Future<void> _selectDate(int index) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _matchSchedules[index].date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _matchSchedules[index] = _matchSchedules[index].copyWith(
          date: pickedDate,
        );
      });
    }
  }

  Future<void> _selectTime(int index) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _matchSchedules[index].time,
    );

    if (pickedTime != null) {
      setState(() {
        _matchSchedules[index] = _matchSchedules[index].copyWith(
          time: pickedTime,
        );
      });
    }
  }

  Future<void> _saveSchedule() async {
    if (_tournamentData == null || _matchSchedules.isEmpty) return;

    try {
      // Create match objects with combined date and time
      final matches = _matchSchedules.map((schedule) {
        final dateTime = DateTime(
          schedule.date.year,
          schedule.date.month,
          schedule.date.day,
          schedule.time.hour,
          schedule.time.minute,
        );

        return TournamentMatch(
          opponent: schedule.opponent,
          result: null, // No result yet
          scorers: [],
          assists: [],
          date: dateTime,
        );
      }).toList();

      // Update tournament data
      final updatedData = _tournamentData!.copyWith(matches: matches);

      // Save to local storage
      final success = await TournamentLocalService.saveTournamentData(updatedData);

      if (mounted) {
        if (success) {
          setState(() {
            _tournamentData = updatedData;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Schedule saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error saving schedule'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error saving schedule: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Schedule'),
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: CoachGuruTheme.mainBlue,
              statusBarIconBrightness: Brightness.light,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => NavHelper.safePop(context),
            ),
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_tournamentData == null) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Schedule'),
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: CoachGuruTheme.mainBlue,
              statusBarIconBrightness: Brightness.light,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => NavHelper.safePop(context),
            ),
          ),
          body: const Center(
            child: Text('Error loading tournament data'),
          ),
        ),
      );
    }

    // Check if opponents exist
    if (_tournamentData!.opponents.isEmpty) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Schedule'),
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: CoachGuruTheme.mainBlue,
              statusBarIconBrightness: Brightness.light,
            ),
            actions: const [ShareButton()],
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => NavHelper.safePop(context),
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 64,
                    color: CoachGuruTheme.textLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please add opponents first.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: CoachGuruTheme.textDark,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Go to Teams screen to add opponents before creating the schedule.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: CoachGuruTheme.textLight,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Schedule'),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: CoachGuruTheme.mainBlue,
            statusBarIconBrightness: Brightness.light,
          ),
          actions: const [ShareButton()],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => NavHelper.safePop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Tournament Schedule',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: CoachGuruTheme.textDark,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Set date and time for each match',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: CoachGuruTheme.textLight,
                      ),
                ),
              ),
              const SizedBox(height: 24),

              // Match Schedule Cards
              ..._matchSchedules.asMap().entries.map((entry) {
                final index = entry.key;
                final schedule = entry.value;
                return _buildMatchScheduleCard(context, schedule, index);
              }),

              const SizedBox(height: 24),

              // Save Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveSchedule,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Schedule'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CoachGuruTheme.mainBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchScheduleCard(
    BuildContext context,
    MatchScheduleItem schedule,
    int index,
  ) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    // Combine date and time for display
    final dateTime = DateTime(
      schedule.date.year,
      schedule.date.month,
      schedule.date.day,
      schedule.time.hour,
      schedule.time.minute,
    );

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      shadowColor: CoachGuruTheme.mainBlue.withOpacity(0.18),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match Number and Opponent
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: CoachGuruTheme.mainBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Match ${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'MyTeam vs ${schedule.opponent}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: CoachGuruTheme.textDark,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date Picker
            InkWell(
              onTap: () => _selectDate(index),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CoachGuruTheme.lightBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CoachGuruTheme.mainBlue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: CoachGuruTheme.mainBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: CoachGuruTheme.textLight,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormat.format(schedule.date),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: CoachGuruTheme.textDark,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: CoachGuruTheme.textLight,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Time Picker
            InkWell(
              onTap: () => _selectTime(index),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CoachGuruTheme.lightBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CoachGuruTheme.mainBlue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: CoachGuruTheme.mainBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: CoachGuruTheme.textLight,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            schedule.time.format(context),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: CoachGuruTheme.textDark,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: CoachGuruTheme.textLight,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper class to manage match schedule items
class MatchScheduleItem {
  final String opponent;
  final DateTime date;
  final TimeOfDay time;

  MatchScheduleItem({
    required this.opponent,
    required this.date,
    required this.time,
  });

  MatchScheduleItem copyWith({
    String? opponent,
    DateTime? date,
    TimeOfDay? time,
  }) {
    return MatchScheduleItem(
      opponent: opponent ?? this.opponent,
      date: date ?? this.date,
      time: time ?? this.time,
    );
  }
}
