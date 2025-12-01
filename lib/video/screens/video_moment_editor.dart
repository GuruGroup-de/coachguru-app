import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/video_analysis_provider.dart';
import '../models/video_analysis_model.dart';
import '../utils/video_thumbnailer.dart';
import '../../theme/theme.dart';

/// Video Moment Editor Screen
/// Allows users to create and edit video moments
class VideoMomentEditor extends StatefulWidget {
  final Duration timestamp;

  const VideoMomentEditor({super.key, required this.timestamp});

  @override
  State<VideoMomentEditor> createState() => _VideoMomentEditorState();
}

class _VideoMomentEditorState extends State<VideoMomentEditor> {
  String _type = 'Shot';
  bool _isSaving = false;

  final List<String> _types = ['Shot', 'Goal', 'Assist', 'Foul', 'Custom'];
  final _commentController = TextEditingController();
  final _playerController = TextEditingController();

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _saveMoment() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a comment'),
          backgroundColor: CoachGuruTheme.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final provider = context.read<VideoAnalysisProvider>();

      if (provider.videoPath == null) {
        throw Exception('No video loaded');
      }

      // Generate thumbnail
      final thumbnail = await VideoThumbnailer.generate(
        provider.videoPath!,
        widget.timestamp,
      );

      // Create moment
      final moment = VideoMoment(
        timestamp: widget.timestamp,
        type: _type,
        comment: _commentController.text.trim(),
        player: _playerController.text.trim().isEmpty
            ? null
            : _playerController.text.trim(),
        thumbnailPath: thumbnail,
      );

      provider.addMoment(moment);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Moment saved successfully!'),
            backgroundColor: CoachGuruTheme.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving moment: $e'),
            backgroundColor: CoachGuruTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CoachGuruTheme.softGrey,
      appBar: AppBar(
        title: const Text('New Moment'),
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
            // Timestamp display
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: CoachGuruTheme.mainBlue,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Timestamp: ${_formatDuration(widget.timestamp)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CoachGuruTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Type selector
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
                      'Moment Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CoachGuruTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _type,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                      items: _types
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _type = v!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Player input
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
                      'Player (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CoachGuruTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _playerController,
                      decoration: InputDecoration(
                        hintText: 'Enter player name',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Comment input
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
                      'Comment *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CoachGuruTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _commentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Describe this moment...',
                        prefixIcon: const Icon(Icons.comment),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveMoment,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.save, size: 24),
                label: Text(
                  _isSaving ? 'Saving...' : 'Save Moment',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
}
