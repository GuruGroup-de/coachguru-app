import 'package:flutter/material.dart';
import '../models/video_analysis_model.dart';
import '../../theme/theme.dart';

/// Timeline Bar Widget
/// Displays video moments on a timeline with seek functionality
class TimelineBar extends StatelessWidget {
  final Duration duration;
  final List<VideoMoment> moments;
  final Function(Duration) onSeek;

  const TimelineBar({
    super.key,
    required this.duration,
    required this.moments,
    required this.onSeek,
  });

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getMomentColor(String type) {
    switch (type) {
      case 'Goal':
        return CoachGuruTheme.accentGreen;
      case 'Shot':
        return CoachGuruTheme.mainBlue;
      case 'Assist':
        return CoachGuruTheme.warningOrange;
      case 'Foul':
        return CoachGuruTheme.errorRed;
      default:
        return CoachGuruTheme.textLight;
    }
  }

  IconData _getMomentIcon(String type) {
    switch (type) {
      case 'Goal':
        return Icons.emoji_events;
      case 'Shot':
        return Icons.sports_soccer;
      case 'Assist':
        return Icons.star;
      case 'Foul':
        return Icons.warning;
      default:
        return Icons.label;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (moments.isEmpty) {
      return Center(
        child: Text(
          'No moments added yet',
          style: TextStyle(color: CoachGuruTheme.textLight, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: moments.length,
      itemBuilder: (ctx, i) {
        final m = moments[i];
        final percent = duration.inMilliseconds > 0
            ? m.timestamp.inMilliseconds / duration.inMilliseconds
            : 0.0;
        final color = _getMomentColor(m.type);
        final icon = _getMomentIcon(m.type);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => onSeek(m.timestamp),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withAlpha((0.15 * 255).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _formatDuration(m.timestamp),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: CoachGuruTheme.textDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withAlpha((0.2 * 255).round()),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                m.type,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (m.player != null) ...[
                          Text(
                            'Player: ${m.player}',
                            style: TextStyle(
                              fontSize: 12,
                              color: CoachGuruTheme.textLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                        if (m.comment.isNotEmpty)
                          Text(
                            m.comment,
                            style: TextStyle(
                              fontSize: 13,
                              color: CoachGuruTheme.textDark,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: percent.clamp(0.0, 1.0),
                          backgroundColor: CoachGuruTheme.softGrey,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
