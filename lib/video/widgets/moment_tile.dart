import 'package:flutter/material.dart';
import 'dart:io';
import '../models/video_analysis_model.dart';
import '../../theme/theme.dart';

/// Moment Tile Widget
/// Displays a video moment with thumbnail and details
class MomentTile extends StatelessWidget {
  final VideoMoment moment;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const MomentTile({
    super.key,
    required this.moment,
    required this.onTap,
    this.onDelete,
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

  @override
  Widget build(BuildContext context) {
    final color = _getMomentColor(moment.type);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              if (moment.thumbnailPath.isNotEmpty &&
                  File(moment.thumbnailPath).existsSync())
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(moment.thumbnailPath),
                    width: 80,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 60,
                        color: CoachGuruTheme.softGrey,
                        child: Icon(
                          Icons.video_library,
                          color: CoachGuruTheme.textLight,
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: CoachGuruTheme.softGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.video_library,
                    color: CoachGuruTheme.textLight,
                  ),
                ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
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
                            moment.type,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDuration(moment.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: CoachGuruTheme.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (moment.player != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        moment.player!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: CoachGuruTheme.textDark,
                        ),
                      ),
                    ],
                    if (moment.comment.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        moment.comment,
                        style: TextStyle(
                          fontSize: 12,
                          color: CoachGuruTheme.textLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Delete button
              if (onDelete != null)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: CoachGuruTheme.errorRed,
                  ),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
