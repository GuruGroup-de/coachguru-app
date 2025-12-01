import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'screenshot_controller.dart';

/// Share Helper
/// Utility class for sharing screenshots
class ShareHelper {
  /// Share the current screen as an image
  static Future<void> shareScreen() async {
    try {
      // Capture screenshot
      final image = await globalScreenshotController.capture();
      if (image == null) {
        return;
      }

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/coachguru_share_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await file.writeAsBytes(image);

      // Share the file
      await Share.shareXFiles([XFile(file.path)], text: 'Shared via CoachGuru');
    } catch (e) {
      print('Share Error: $e');
      // Optionally show error to user
    }
  }
}
