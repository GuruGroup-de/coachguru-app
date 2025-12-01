import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/video_analysis_provider.dart';
import 'video_player_screen.dart';
import '../../theme/theme.dart';

/// Video Import Screen
/// Allows users to import videos from gallery for analysis
class VideoImportScreen extends StatelessWidget {
  const VideoImportScreen({super.key});

  Future<void> _importVideo(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final video = await picker.pickVideo(source: ImageSource.gallery);

      if (video != null) {
        final provider = context.read<VideoAnalysisProvider>();
        provider.setVideo(video.path);

        if (context.mounted) {
          try {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoPlayerScreen(videoPath: video.path),
              ),
            );
          } catch (e) {
            print('Navigation error: $e');
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing video: $e'),
            backgroundColor: CoachGuruTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CoachGuruTheme.softGrey,
      appBar: AppBar(
        title: const Text('Video Analysis'),
        backgroundColor: CoachGuruTheme.mainBlue,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: CoachGuruTheme.mainBlue,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library,
                size: 100,
                color: CoachGuruTheme.mainBlue,
              ),
              const SizedBox(height: 24),
              Text(
                'Video Analysis',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: CoachGuruTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Import a video to start analyzing key moments',
                style: TextStyle(fontSize: 16, color: CoachGuruTheme.textLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => _importVideo(context),
                icon: const Icon(Icons.video_library, size: 24),
                label: const Text(
                  'Import Video',
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
            ],
          ),
        ),
      ),
    );
  }
}
