import 'package:flutter/material.dart';
import '../models/player_icon.dart';

/// Player Icon Widget
/// Draggable player icon with free movement
class PlayerIconWidget extends StatelessWidget {
  final PlayerIcon player;
  final Function(Offset) onPositionChanged;
  final BoxConstraints constraints;

  const PlayerIconWidget({
    super.key,
    required this.player,
    required this.onPositionChanged,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    // Clamp position to container bounds (accounting for icon size)
    final iconSize = 40.0;
    final halfIcon = iconSize / 2;
    final clampedX = player.position.dx.clamp(
      halfIcon,
      constraints.maxWidth - halfIcon,
    );
    final clampedY = player.position.dy.clamp(
      halfIcon,
      constraints.maxHeight - halfIcon,
    );

    return Positioned(
      left: clampedX - halfIcon,
      top: clampedY - halfIcon,
      child: GestureDetector(
        onPanUpdate: (details) {
          try {
            // Calculate new position
            final newX = player.position.dx + details.delta.dx;
            final newY = player.position.dy + details.delta.dy;

            // Clamp to container bounds (accounting for icon size)
            final clampedNewX = newX.clamp(
              halfIcon,
              constraints.maxWidth - halfIcon,
            );
            final clampedNewY = newY.clamp(
              halfIcon,
              constraints.maxHeight - halfIcon,
            );

            final newPosition = Offset(clampedNewX, clampedNewY);
            onPositionChanged(newPosition);
          } catch (e) {
            print('[PlayerIconWidget] Error in onPanUpdate: $e');
          }
        },
        child: Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: player.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.3 * 255).round()),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              player.number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
