import 'package:flutter/material.dart';

/// Navigation Helper
/// Provides safe navigation methods to prevent crashes and black screens
class NavHelper {
  /// Safely pops the current route
  /// If can't pop, navigates to home screen
  static void safePop(BuildContext context) {
    try {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        // Fallback: navigate to home if we can't pop
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      print('Navigation error in safePop: $e');
      // Last resort: try to navigate to home
      try {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } catch (e2) {
        print('Failed to navigate to home: $e2');
      }
    }
  }

  /// Safely pops a dialog
  /// Uses rootNavigator to ensure dialog is closed correctly
  static void safePopDialog(BuildContext context) {
    try {
      Navigator.of(context, rootNavigator: true).pop();
    } catch (e) {
      print('Navigation error in safePopDialog: $e');
      // Fallback to regular pop
      try {
        Navigator.pop(context);
      } catch (e2) {
        print('Failed to pop dialog: $e2');
      }
    }
  }

  /// Safely navigates to a route
  static Future<void> safePush(BuildContext context, Widget screen) async {
    try {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    } catch (e) {
      print('Navigation error in safePush: $e');
    }
  }
}
