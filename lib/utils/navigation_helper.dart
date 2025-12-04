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
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      print('Navigation error in safePop: $e');
      // Last resort: try to navigate to home
      try {
        Navigator.pushReplacementNamed(context, '/');
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

  /// Safely navigates to a route (route name as String)
  /// If route is missing, falls back to home route
  static Future<void> safePush(BuildContext context, String route) async {
    try {
      if (!context.mounted) return;
      
      // Use pushNamed with try/catch
      await Navigator.pushNamed(context, route);
    } catch (e) {
      print('Navigation error in safePush ($route): $e');
      // Fallback to home route if route is missing
      try {
        if (context.mounted) {
          await Navigator.pushReplacementNamed(context, '/');
        }
      } catch (e2) {
        print('Failed to navigate to home: $e2');
      }
    }
  }

  /// Safely navigates to a screen (Widget)
  static Future<void> safePushWidget(BuildContext context, Widget screen) async {
    try {
      if (!context.mounted) return;
      await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    } catch (e) {
      print('Navigation error in safePushWidget: $e');
    }
  }

  /// Safely navigates to a named route
  /// If route is missing, falls back to HomeScreen
  static Future<void> safePushNamed(BuildContext context, String routeName) async {
    try {
      if (!context.mounted) return;
      
      // Try to push the named route
      await Navigator.pushNamed(context, routeName);
    } catch (e) {
      print('Navigation error in safePushNamed ($routeName): $e');
      // Fallback: try to navigate to home route
      try {
        if (context.mounted) {
          await Navigator.pushReplacementNamed(context, '/');
        }
      } catch (e2) {
        print('Failed to navigate to home: $e2');
      }
    }
  }
}
