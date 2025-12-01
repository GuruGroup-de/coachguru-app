import 'package:flutter/material.dart';
import '../utils/share_helper.dart';

/// Global Share Button Widget
/// Reusable share button for AppBars
class ShareButton extends StatelessWidget {
  const ShareButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share, size: 26),
      onPressed: ShareHelper.shareScreen,
      tooltip: 'Share',
    );
  }
}
