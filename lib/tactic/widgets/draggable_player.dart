import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tactic_provider.dart';
import '../../theme/theme.dart';

/// Draggable Player Widget
/// Represents a player that can be dragged on the tactic board
class DraggablePlayer extends StatelessWidget {
  final String id;
  final double x;
  final double y;

  const DraggablePlayer({
    super.key,
    required this.id,
    required this.x,
    required this.y,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: Draggable(
        feedback: _buildBall(),
        childWhenDragging: Opacity(opacity: 0.3, child: _buildBall()),
        onDragEnd: (details) {
          final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            // Get the parent RenderBox (the Stack container)
            final parentRenderObject = renderBox.parent;
            if (parentRenderObject is RenderBox) {
              final parentSize = parentRenderObject.size;
              final localPosition = renderBox.globalToLocal(details.offset);
              // Convert to percentage (0-100) and adjust for player size
              final playerSize = 42.0;
              final newX =
                  (((localPosition.dx - playerSize / 2) / parentSize.width) *
                          100)
                      .clamp(0.0, 100.0);
              final newY =
                  (((localPosition.dy - playerSize / 2) / parentSize.height) *
                          100)
                      .clamp(0.0, 100.0);
              // Determine team based on id (blue or red)
              final isBlue = id.startsWith('blue');
              context.read<TacticProvider>().updatePlayerPosition(
                id,
                Offset(newX, newY),
                isBlue,
              );
            } else {
              // Fallback: use screen coordinates
              final screenSize = MediaQuery.of(context).size;
              final newX = ((details.offset.dx / screenSize.width) * 100).clamp(
                0.0,
                100.0,
              );
              final newY = ((details.offset.dy / screenSize.height) * 100)
                  .clamp(0.0, 100.0);
              // Determine team based on id (blue or red)
              final isBlue = id.startsWith('blue');
              context.read<TacticProvider>().updatePlayerPosition(
                id,
                Offset(newX, newY),
                isBlue,
              );
            }
          }
        },
        child: _buildBall(),
      ),
    );
  }

  Widget _buildBall() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: CoachGuruTheme.white,
        shape: BoxShape.circle,
        border: Border.all(color: CoachGuruTheme.mainBlue, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.26 * 255).round()),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        id.replaceAll('P', ''),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: CoachGuruTheme.mainBlue,
        ),
      ),
    );
  }
}
