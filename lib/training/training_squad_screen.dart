import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../theme/theme.dart';
import '../player/player_provider.dart';
import 'providers/training_attendance_provider.dart';
import 'training_statistics_screen.dart';
import 'widgets/attendance_chip.dart';
import 'widgets/training_type_chip.dart';
import 'package:screenshot/screenshot.dart';
import '../utils/screenshot_controller.dart';
import '../widgets/share_button.dart';

class TrainingSquadScreen extends StatefulWidget {
  const TrainingSquadScreen({super.key});

  @override
  State<TrainingSquadScreen> createState() => _TrainingSquadScreenState();
}

class _TrainingSquadScreenState extends State<TrainingSquadScreen> {
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: CoachGuruTheme.mainBlue,
              onPrimary: Colors.white,
              onSurface: CoachGuruTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrainingAttendanceProvider>().loadAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: globalScreenshotController,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        body: Column(
          children: [
            Container(
              height: 110,
              padding: const EdgeInsets.only(left: 16, top: 40, bottom: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Training Squad',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy',
                        ).format(DateFormat('yyyy-MM-dd').parse(_selectedDate)),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  const ShareButton(),
                ],
              ),
            ),
            Expanded(
              child: Consumer2<PlayerProvider, TrainingAttendanceProvider>(
                builder: (context, playerProvider, attendanceProvider, child) {
                  if (!context.mounted) return const SizedBox();
                  if (playerProvider.isLoading ||
                      attendanceProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final players = playerProvider.players;

                  if (players.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group_outlined,
                            size: 64,
                            color: CoachGuruTheme.textLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No players in squad',
                            style: TextStyle(
                              fontSize: 18,
                              color: CoachGuruTheme.textLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add players from Team Management',
                            style: TextStyle(
                              fontSize: 14,
                              color: CoachGuruTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                CoachGuruTheme.mainBlue,
                                CoachGuruTheme.mainBlue.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Date:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: _pickDate,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: CoachGuruTheme.mainBlue,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: Text(
                                  DateFormat('MMM dd, yyyy').format(
                                    DateFormat(
                                      'yyyy-MM-dd',
                                    ).parse(_selectedDate),
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Session Type:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: CoachGuruTheme.textDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Row(
                                  children: [
                                    TrainingTypeChip(
                                      label: 'Training',
                                      selected:
                                          attendanceProvider
                                              .selectedSessionType ==
                                          'Training',
                                      onTap: () {
                                        attendanceProvider
                                            .setSelectedSessionType('Training');
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    TrainingTypeChip(
                                      label: 'Match',
                                      selected:
                                          attendanceProvider
                                              .selectedSessionType ==
                                          'Match',
                                      onTap: () {
                                        attendanceProvider
                                            .setSelectedSessionType('Match');
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    TrainingTypeChip(
                                      label: 'Fitness',
                                      selected:
                                          attendanceProvider
                                              .selectedSessionType ==
                                          'Fitness',
                                      onTap: () {
                                        attendanceProvider
                                            .setSelectedSessionType('Fitness');
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.bar_chart),
                            label: const Text('Graphics'),
                            onPressed: () {
                              try {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const TrainingStatisticsScreen(),
                                  ),
                                );
                              } catch (e) {
                                print('Navigation error: $e');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CoachGuruTheme.accentGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: players.length,
                            itemBuilder: (context, index) {
                              final player = players[index];
                              final currentAttendance =
                                  attendanceProvider.getAttendanceForPlayer(
                                    player.id,
                                    _selectedDate,
                                    attendanceProvider.selectedSessionType,
                                  ) ??
                                  'No';

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  leading: Hero(
                                    tag: 'player_avatar_${player.id}',
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: CoachGuruTheme.lightBlue,
                                      child: player.photoPath != null
                                          ? ClipOval(
                                              child: Image.file(
                                                File(player.photoPath!),
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Icon(
                                                        Icons.person,
                                                        color: CoachGuruTheme
                                                            .mainBlue,
                                                        size: 30,
                                                      );
                                                    },
                                              ),
                                            )
                                          : Icon(
                                              Icons.person,
                                              color: CoachGuruTheme.mainBlue,
                                              size: 30,
                                            ),
                                    ),
                                  ),
                                  title: Text(
                                    player.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: CoachGuruTheme.textDark,
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'Tap to set attendance',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: CoachGuruTheme.textLight,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AttendanceChip(
                                        label: 'YES',
                                        color: Colors.green,
                                        selected: currentAttendance == 'Yes',
                                        onTap: () {
                                          attendanceProvider.updateAttendance(
                                            player.id,
                                            _selectedDate,
                                            attendanceProvider
                                                .selectedSessionType,
                                            'Yes',
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      AttendanceChip(
                                        label: 'NO',
                                        color: Colors.red,
                                        selected: currentAttendance == 'No',
                                        onTap: () {
                                          attendanceProvider.updateAttendance(
                                            player.id,
                                            _selectedDate,
                                            attendanceProvider
                                                .selectedSessionType,
                                            'No',
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
