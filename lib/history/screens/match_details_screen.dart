import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/match_model.dart';
import '../../theme/theme.dart';
import '../../stats/screens/match_stats_screen.dart';
import '../../stats/providers/match_stats_provider.dart';

/// Match Details Screen
/// Displays detailed information about a match
class MatchDetailsScreen extends StatelessWidget {
  final MatchModel match;

  const MatchDetailsScreen({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CoachGuruTheme.softGrey,
      appBar: AppBar(
        title: Text('${match.opponent} • ${match.result}'),
        backgroundColor: CoachGuruTheme.mainBlue,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: CoachGuruTheme.mainBlue,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match Header Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [CoachGuruTheme.mainBlue, CoachGuruTheme.lightBlue],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              match.opponent,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat(
                                'EEEE, MMMM dd, yyyy',
                              ).format(match.date),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withAlpha(
                                  (0.9 * 255).round(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          match.result,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.2 * 255).round()),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            match.type == 'League'
                                ? Icons.emoji_events
                                : Icons.sports_soccer,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            match.type,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Statistics Card
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
                      'Statistics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CoachGuruTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatItem(
                          context,
                          Icons.sports_soccer,
                          'Goals',
                          match.goals.toString(),
                          CoachGuruTheme.mainBlue,
                        ),
                        const SizedBox(width: 16),
                        _buildStatItem(
                          context,
                          Icons.star,
                          'Assists',
                          match.assists.toString(),
                          CoachGuruTheme.accentGreen,
                        ),
                        const SizedBox(width: 16),
                        _buildStatItem(
                          context,
                          Icons.timer,
                          'Minutes',
                          match.minutesPlayed.toString(),
                          CoachGuruTheme.warningOrange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Scorers Card
            if (match.scorers.isNotEmpty) ...[
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
                      Row(
                        children: [
                          Icon(
                            Icons.sports_soccer,
                            color: CoachGuruTheme.mainBlue,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Scorers',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: CoachGuruTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...match.scorers.map((scorer) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: CoachGuruTheme.mainBlue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                scorer,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: CoachGuruTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Timeline Card
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
                    Row(
                      children: [
                        Icon(
                          Icons.timeline,
                          color: CoachGuruTheme.mainBlue,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Timeline',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: CoachGuruTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (match.timeline.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'No timeline events recorded',
                            style: TextStyle(
                              fontSize: 14,
                              color: CoachGuruTheme.textLight,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      )
                    else
                      ...match.timeline.map((event) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: CoachGuruTheme.lightBlue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${event['minute']}'",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: CoachGuruTheme.mainBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "${event['event']} - ${event['player']}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: CoachGuruTheme.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // View Stats Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Load stats if available
                  final statsProvider = context.read<MatchStatsProvider>();
                  if (match.stats != null) {
                    statsProvider.loadStats(match.stats);
                  } else {
                    statsProvider.reset();
                  }

                  try {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MatchStatsScreen(matchId: match.id),
                      ),
                    );
                  } catch (e) {
                    print('Navigation error: $e');
                  }
                },
                icon: const Icon(Icons.bar_chart, size: 24),
                label: const Text(
                  'View Match Stats',
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CoachGuruTheme.textDark,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: CoachGuruTheme.textLight),
            ),
          ],
        ),
      ),
    );
  }
}
