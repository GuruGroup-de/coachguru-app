import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/match_stats_provider.dart';
import '../widgets/stat_button.dart';
import '../widgets/stats_summary_card.dart';
import '../../theme/theme.dart';
import 'stats_overview_screen.dart';

/// Match Stats Screen
/// Interactive screen for tracking match statistics in real-time
class MatchStatsScreen extends StatelessWidget {
  final String matchId;

  const MatchStatsScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchStatsProvider>();
    final stats = provider.stats;

    return Scaffold(
      backgroundColor: CoachGuruTheme.softGrey,
      appBar: AppBar(
        title: const Text('Match Stats'),
        backgroundColor: CoachGuruTheme.mainBlue,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: CoachGuruTheme.mainBlue,
          statusBarIconBrightness: Brightness.light,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Stats',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Statistics'),
                  content: const Text(
                    'Are you sure you want to reset all statistics?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        provider.reset();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Statistics reset'),
                            backgroundColor: CoachGuruTheme.accentGreen,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CoachGuruTheme.errorRed,
                      ),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Summary Card
            StatsSummaryCard(stats: stats, title: 'Current Statistics'),
            const SizedBox(height: 24),

            // General Stats Section
            Text(
              'General Stats',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: CoachGuruTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),

            // Stat Buttons
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                StatButton(
                  label: 'Shot',
                  icon: Icons.sports_soccer,
                  onPressed: () => provider.increment('shots'),
                ),
                StatButton(
                  label: 'Shot On Target',
                  icon: Icons.gps_fixed,
                  onPressed: () => provider.increment('shotsOnTarget'),
                ),
                StatButton(
                  label: 'Goal',
                  icon: Icons.emoji_events,
                  onPressed: () => provider.increment('goals'),
                ),
                StatButton(
                  label: 'Assist',
                  icon: Icons.star,
                  onPressed: () => provider.increment('assists'),
                ),
                StatButton(
                  label: 'Pass',
                  icon: Icons.swap_horiz,
                  onPressed: () => provider.increment('passes'),
                ),
                StatButton(
                  label: 'Successful Pass',
                  icon: Icons.check_circle,
                  onPressed: () => provider.increment('successfulPasses'),
                ),
                StatButton(
                  label: 'Duel Won',
                  icon: Icons.trending_up,
                  onPressed: () => provider.increment('duelsWon'),
                ),
                StatButton(
                  label: 'Duel Lost',
                  icon: Icons.trending_down,
                  onPressed: () => provider.increment('duelsLost'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Possession Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Possession',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CoachGuruTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      min: 0,
                      max: 100,
                      value: stats.possessionOur.toDouble(),
                      activeColor: CoachGuruTheme.mainBlue,
                      inactiveColor: CoachGuruTheme.softGrey,
                      onChanged: (val) {
                        provider.updatePossession(
                          val.toInt(),
                          100 - val.toInt(),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Our team: ${stats.possessionOur}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: CoachGuruTheme.mainBlue,
                          ),
                        ),
                        Text(
                          'Opponent: ${stats.possessionOpponent}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: CoachGuruTheme.errorRed,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // View Full Stats Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  try {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StatsOverviewScreen(),
                      ),
                    );
                  } catch (e) {
                    print('Navigation error: $e');
                  }
                },
                icon: const Icon(Icons.bar_chart, size: 24),
                label: const Text(
                  'View Full Stats Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CoachGuruTheme.mainBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
