import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/video_analysis_provider.dart';
import 'video_moment_editor.dart';
import '../widgets/timeline_bar.dart';
import '../../theme/theme.dart';

/// Video Player Screen
/// Main screen for video playback and moment creation
class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoPlayerController = VideoPlayerController.file(
        File(widget.videoPath),
      );

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: CoachGuruTheme.mainBlue,
          handleColor: CoachGuruTheme.mainBlue,
          backgroundColor: CoachGuruTheme.softGrey,
          bufferedColor: CoachGuruTheme.lightBlue,
        ),
      );

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading video: $e'),
            backgroundColor: CoachGuruTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VideoAnalysisProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Analyze Video'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Column(
        children: [
          // Video Player
          if (_isInitialized && _chewieController != null)
            Expanded(
              child: AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              ),
            )
          else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Loading video...',
                      style: TextStyle(color: CoachGuruTheme.textLight),
                    ),
                  ],
                ),
              ),
            ),

          // Timeline Bar
          Container(
            height: 200,
            color: CoachGuruTheme.softGrey,
            child: _isInitialized && _videoPlayerController != null
                ? TimelineBar(
                    duration: _videoPlayerController!.value.duration,
                    moments: provider.moments,
                    onSeek: (duration) {
                      _videoPlayerController?.seekTo(duration);
                    },
                  )
                : const Center(child: Text('Video not loaded')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isInitialized && _videoPlayerController != null
            ? () {
                final timestamp = _videoPlayerController!.value.position;
                try {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoMomentEditor(timestamp: timestamp),
                    ),
                  );
                } catch (e) {
                  print('Navigation error: $e');
                }
              }
            : null,
        backgroundColor: CoachGuruTheme.mainBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Moment'),
      ),
    );
  }
}
