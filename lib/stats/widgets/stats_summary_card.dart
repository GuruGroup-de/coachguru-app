import 'package:flutter/material.dart';
import '../models/match_stats_model.dart';
import '../../theme/theme.dart';

/// Stats Summary Card Widget
/// Displays a summary of match statistics in a card format
class StatsSummaryCard extends StatelessWidget {
  final MatchStatsModel stats;
  final String title;

  const StatsSummaryCard({super.key, required this.stats, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: CoachGuruTheme.mainBlue.withAlpha((0.18 * 255).round()),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CoachGuruTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow(context, 'Shots', stats.shots.toString()),
            _buildStatRow(
              context,
              'Shots on Target',
              stats.shotsOnTarget.toString(),
            ),
            _buildStatRow(context, 'Goals', stats.goals.toString()),
            _buildStatRow(context, 'Assists', stats.assists.toString()),
            _buildStatRow(context, 'Passes', stats.passes.toString()),
            _buildStatRow(
              context,
              'Successful Passes',
              stats.successfulPasses.toString(),
            ),
            _buildStatRow(
              context,
              'Pass Accuracy',
              '${stats.passAccuracy.toStringAsFixed(1)}%',
            ),
            _buildStatRow(context, 'Duels Won', stats.duelsWon.toString()),
            _buildStatRow(context, 'Duels Lost', stats.duelsLost.toString()),
            _buildStatRow(
              context,
              'Duel Win Rate',
              '${stats.duelWinRate.toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 12),
            Divider(color: CoachGuruTheme.softGrey),
            const SizedBox(height: 12),
            _buildPossessionRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: CoachGuruTheme.textDark),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CoachGuruTheme.mainBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPossessionRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Possession',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CoachGuruTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CoachGuruTheme.mainBlue.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Our Team',
                      style: TextStyle(
                        fontSize: 12,
                        color: CoachGuruTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stats.possessionOur}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CoachGuruTheme.mainBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CoachGuruTheme.errorRed.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Opponent',
                      style: TextStyle(
                        fontSize: 12,
                        color: CoachGuruTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stats.possessionOpponent}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CoachGuruTheme.errorRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
