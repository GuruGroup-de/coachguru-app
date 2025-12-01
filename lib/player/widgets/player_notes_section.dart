import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/scouting_provider.dart';
import '../../models/scouting_note.dart';
import '../../theme/theme.dart';
import '../../scouting/scouting_template_screen.dart';

/// Player Notes Section Widget
/// Displays the last 3 scouting notes for a player
class PlayerNotesSection extends StatelessWidget {
  final String playerId;

  const PlayerNotesSection({super.key, required this.playerId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScoutingProvider>(
      builder: (context, scoutingProvider, child) {
        if (!context.mounted) return const SizedBox();
        final allNotes = scoutingProvider.notesForPlayer(playerId);
        final recentNotes = allNotes.length > 3
            ? allNotes.take(3).toList()
            : allNotes;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SCOUTING NOTES',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CoachGuruTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            if (recentNotes.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: CoachGuruTheme.softGrey,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'No scouting notes yet',
                    style: TextStyle(
                      color: CoachGuruTheme.textLight,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ...recentNotes.asMap().entries.map((entry) {
                final index = entry.key;
                final note = entry.value;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: _buildNoteCard(context, note, index),
                );
              }),
            const SizedBox(height: 16),
            Row(
              children: [
                if (allNotes.length > 3)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to full notes list screen
                        debugPrint('View all notes for player $playerId');
                      },
                      icon: const Icon(Icons.list, size: 18),
                      label: const Text('View All'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CoachGuruTheme.mainBlue,
                        side: BorderSide(color: CoachGuruTheme.mainBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (allNotes.length > 3) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      try {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ScoutingTemplateScreen(playerId: playerId),
                          ),
                        );
                      } catch (e) {
                        print('Navigation error: $e');
                      }
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('+ New Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CoachGuruTheme.mainBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildNoteCard(BuildContext context, ScoutingNote note, int index) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: CoachGuruTheme.mainBlue.withAlpha((0.1 * 255).round()),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.remove_red_eye_outlined,
                  size: 18,
                  color: CoachGuruTheme.mainBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM dd, yyyy').format(note.date),
                  style: textTheme.bodySmall?.copyWith(
                    color: CoachGuruTheme.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (note.strengths.isNotEmpty) ...[
              _buildNoteRow(
                'Strengths',
                note.strengths,
                CoachGuruTheme.accentGreen,
              ),
              const SizedBox(height: 8),
            ],
            if (note.potential.isNotEmpty) ...[
              _buildNoteRow(
                'Potential',
                note.potential,
                CoachGuruTheme.warningOrange,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoteRow(String label, String value, Color color) {
    final displayValue = value.length > 80
        ? '${value.substring(0, 80)}...'
        : value;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withAlpha((0.15 * 255).round()),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            displayValue,
            style: TextStyle(
              fontSize: 13,
              color: CoachGuruTheme.textDark,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
