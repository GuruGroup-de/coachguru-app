import 'package:video_thumbnail/video_thumbnail.dart';

/// Video Thumbnailer Utility
/// Generates thumbnails from video at specific timestamps
class VideoThumbnailer {
  /// Generate a thumbnail from video at a specific moment
  static Future<String> generate(String videoPath, Duration moment) async {
    try {
      final thumb = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        timeMs: moment.inMilliseconds,
        imageFormat: ImageFormat.PNG,
        maxWidth: 512,
        quality: 75,
      );

      return thumb ?? '';
    } catch (e) {
      // Return empty string if thumbnail generation fails
      return '';
    }
  }

  /// Generate multiple thumbnails for a list of moments
  static Future<List<String>> generateMultiple(
    String videoPath,
    List<Duration> moments,
  ) async {
    final thumbnails = <String>[];

    for (final moment in moments) {
      final thumb = await generate(videoPath, moment);
      if (thumb.isNotEmpty) {
        thumbnails.add(thumb);
      }
    }

    return thumbnails;
  }
}
