import 'package:flutter/material.dart';

/// Pitch Background Widget
/// Creates a beautiful green football pitch background
class PitchBackground extends StatelessWidget {
  const PitchBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF2E7D32), // Dark green
            const Color(0xFF4CAF50), // Medium green
            const Color(0xFF66BB6A), // Light green
          ],
        ),
      ),
      child: CustomPaint(painter: PitchPainter(), child: Container()),
    );
  }
}

/// Custom painter for drawing pitch lines
class PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha((0.7 * 255).round())
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Center line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.15,
      paint,
    );

    // Center dot
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      3,
      Paint()..color = Colors.white,
    );

    // Top penalty area
    final topPenaltyWidth = size.width * 0.4;
    final topPenaltyHeight = size.height * 0.2;
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - topPenaltyWidth) / 2,
        0,
        topPenaltyWidth,
        topPenaltyHeight,
      ),
      paint,
    );

    // Top goal area
    final topGoalWidth = size.width * 0.25;
    final topGoalHeight = size.height * 0.1;
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - topGoalWidth) / 2,
        0,
        topGoalWidth,
        topGoalHeight,
      ),
      paint,
    );

    // Bottom penalty area
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - topPenaltyWidth) / 2,
        size.height - topPenaltyHeight,
        topPenaltyWidth,
        topPenaltyHeight,
      ),
      paint,
    );

    // Bottom goal area
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - topGoalWidth) / 2,
        size.height - topGoalHeight,
        topGoalWidth,
        topGoalHeight,
      ),
      paint,
    );

    // Corner arcs
    final cornerRadius = 20.0;
    canvas.drawArc(
      Rect.fromLTWH(0, 0, cornerRadius * 2, cornerRadius * 2),
      0,
      -1.57,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        size.width - cornerRadius * 2,
        0,
        cornerRadius * 2,
        cornerRadius * 2,
      ),
      1.57,
      -1.57,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        0,
        size.height - cornerRadius * 2,
        cornerRadius * 2,
        cornerRadius * 2,
      ),
      -1.57,
      -1.57,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        size.width - cornerRadius * 2,
        size.height - cornerRadius * 2,
        cornerRadius * 2,
        cornerRadius * 2,
      ),
      3.14,
      -1.57,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
