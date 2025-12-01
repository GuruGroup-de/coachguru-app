import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'player_model.dart';
import 'player_provider.dart';
import 'match_performance.dart';
import 'edit_player_screen.dart';
import '../theme/theme.dart';
import '../utils/navigation_helper.dart';
import 'widgets/player_notes_section.dart';

/// Player Profile Screen
/// Beautiful modern player profile with gradient header and detailed sections
class PlayerProfileScreen extends StatelessWidget {
  final PlayerModel player;
  final PlayerProvider provider;

  const PlayerProfileScreen({
    super.key,
    required this.player,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CoachGuruTheme.softGrey,
      body: CustomScrollView(
        slivers: [
          // SliverAppBar with gradient background
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => NavHelper.safePop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  try {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPlayerScreen(player: player),
                      ),
                    );
                  } catch (e) {
                    print('Navigation error: $e');
                  }
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF005BEA), Color(0xFF00C6FB)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Hero Avatar
                      Hero(
                        tag: 'player_avatar_${player.id}',
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white.withAlpha(
                            (0.3 * 255).round(),
                          ),
                          child:
                              player.photoPath != null &&
                                  File(player.photoPath!).existsSync()
                              ? ClipOval(
                                  child: Image.file(
                                    File(player.photoPath!),
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Player Name
                      Text(
                        player.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Position
                      Text(
                        player.position,
                        style: TextStyle(
                          color: Colors.white.withAlpha((0.9 * 255).round()),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Body Content
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.1 * 255).round()),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Player Details Card
                    _buildPlayerDetailsCard(),
                    const SizedBox(height: 20),

                    // Statistics Section
                    _buildStatisticsSection(),
                    const SizedBox(height: 20),

                    // Match History Section
                    _buildMatchHistorySection(),
                    const SizedBox(height: 20),

                    // Scouting Notes Section
                    PlayerNotesSection(playerId: player.id),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          try {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPlayerScreen(player: player),
              ),
            );
          } catch (e) {
            print('Navigation error: $e');
          }
        },
        backgroundColor: CoachGuruTheme.mainBlue,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildPlayerDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: CoachGuruTheme.mainBlue.withAlpha((0.18 * 255).round()),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PLAYER DETAILS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CoachGuruTheme.textDark,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Birth Year',
              value: '${player.birthYear} (Age ${player.age})',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.sports_soccer,
              label: 'Strong Foot',
              value: player.strongFoot,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              icon: Icons.person,
              label: 'Position',
              value: player.position,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CoachGuruTheme.lightBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: CoachGuruTheme.mainBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: CoachGuruTheme.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: CoachGuruTheme.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STATISTICS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CoachGuruTheme.textDark,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatBox(
                icon: Icons.sports_soccer,
                label: 'Goals',
                value: player.goals.toString(),
                color: CoachGuruTheme.mainBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatBox(
                icon: Icons.star,
                label: 'Assists',
                value: player.assists.toString(),
                color: CoachGuruTheme.accentGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatBox(
                icon: Icons.event,
                label: 'Matches',
                value: player.matchHistory.length.toString(),
                color: CoachGuruTheme.warningOrange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withAlpha((0.3 * 255).round()),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CoachGuruTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: CoachGuruTheme.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchHistorySection() {
    final sortedHistory = List<MatchPerformance>.from(player.matchHistory)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MATCH HISTORY',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CoachGuruTheme.textDark,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        if (sortedHistory.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: CoachGuruTheme.softGrey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'No match history yet',
                style: TextStyle(
                  color: CoachGuruTheme.textLight,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ...sortedHistory.map((match) => _buildMatchCard(match)),
      ],
    );
  }

  Widget _buildMatchCard(MatchPerformance match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CoachGuruTheme.lightBlue, width: 1),
        boxShadow: [
          BoxShadow(
            color: CoachGuruTheme.mainBlue.withAlpha((0.1 * 255).round()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM dd, yyyy').format(match.date),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CoachGuruTheme.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: CoachGuruTheme.lightBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${match.minutes} min',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CoachGuruTheme.mainBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (match.goals > 0) ...[
                Row(
                  children: [
                    const Text('⚽ ', style: TextStyle(fontSize: 18)),
                    Text(
                      '${match.goals}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CoachGuruTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
              ],
              if (match.assists > 0) ...[
                Row(
                  children: [
                    const Text('🎯 ', style: TextStyle(fontSize: 18)),
                    Text(
                      '${match.assists}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CoachGuruTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          if (match.note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CoachGuruTheme.softGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                match.note,
                style: TextStyle(
                  fontSize: 13,
                  color: CoachGuruTheme.textLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
