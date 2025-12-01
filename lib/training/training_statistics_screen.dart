import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme.dart';
import '../player/player_provider.dart';
import '../player/player_model.dart';
import 'providers/training_attendance_provider.dart';
import 'package:screenshot/screenshot.dart';
import '../utils/screenshot_controller.dart';
import '../widgets/share_button.dart';

class TrainingStatisticsScreen extends StatefulWidget {
  const TrainingStatisticsScreen({super.key});

  @override
  State<TrainingStatisticsScreen> createState() =>
      _TrainingStatisticsScreenState();
}

class _TrainingStatisticsScreenState extends State<TrainingStatisticsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: globalScreenshotController,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        body: Column(
          children: [
            Container(
              height: 120,
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
                        'Attendance Statistics',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Real-time auto-updated',
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

                  final players = List<PlayerModel>.from(
                    playerProvider.players,
                  );

                  if (players.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart_outlined,
                            size: 64,
                            color: CoachGuruTheme.textLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No players found',
                            style: TextStyle(
                              fontSize: 18,
                              color: CoachGuruTheme.textLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add players to see statistics',
                            style: TextStyle(
                              fontSize: 14,
                              color: CoachGuruTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final Map<String, double> attendancePercent = {};
                  for (final player in players) {
                    attendancePercent[player.id] = attendanceProvider
                        .getAttendancePercentage(player.id);
                  }

                  double averageAttendance = 0.0;
                  if (attendancePercent.isNotEmpty) {
                    final total = attendancePercent.values.reduce(
                      (a, b) => a + b,
                    );
                    averageAttendance = total / attendancePercent.length;
                  }

                  List<PlayerModel> filteredPlayers = List.from(players);
                  if (_selectedFilter == 'Top') {
                    filteredPlayers = players
                        .where((p) => (attendancePercent[p.id] ?? 0.0) > 80)
                        .toList();
                  } else if (_selectedFilter == 'Low') {
                    filteredPlayers = players
                        .where((p) => (attendancePercent[p.id] ?? 0.0) < 40)
                        .toList();
                  }

                  filteredPlayers.sort(
                    (a, b) => attendancePercent[b.id]!.compareTo(
                      attendancePercent[a.id]!,
                    ),
                  );

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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Team Average',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${averageAttendance.round()}%',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(
                                Icons.trending_up,
                                color: Colors.white,
                                size: 32,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildFilterButton(
                                'All',
                                _selectedFilter == 'All',
                                () => setState(() => _selectedFilter = 'All'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildFilterButton(
                                'Top Performers',
                                _selectedFilter == 'Top',
                                () => setState(() => _selectedFilter = 'Top'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildFilterButton(
                                'Low Attendance',
                                _selectedFilter == 'Low',
                                () => setState(() => _selectedFilter = 'Low'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: filteredPlayers.isEmpty
                              ? Center(
                                  child: Text(
                                    'No players match the selected filter',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: CoachGuruTheme.textLight,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filteredPlayers.length,
                                  itemBuilder: (context, index) {
                                    final player = filteredPlayers[index];
                                    final percentage =
                                        attendancePercent[player.id] ?? 0.0;

                                    return Card(
                                      elevation: 2,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 120,
                                              child: Text(
                                                player.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      CoachGuruTheme.textDark,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Container(
                                                height: 14,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: FractionallySizedBox(
                                                  widthFactor: percentage / 100,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient:
                                                          const LinearGradient(
                                                            colors: [
                                                              Color(0xFF66BB6A),
                                                              Color(0xFF43A047),
                                                            ],
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: percentage > 80
                                                    ? Colors.green
                                                    : Colors.orange,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                '${percentage.round()}%',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
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

  Widget _buildFilterButton(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? CoachGuruTheme.mainBlue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? null
              : Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
