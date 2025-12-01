import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/theme.dart';

class TacticScreen extends StatefulWidget {
  @override
  _TacticScreenState createState() => _TacticScreenState();
}

class _TacticScreenState extends State<TacticScreen> {
  List<DraggablePlayer> _playersOnPitch = [];
  List<DraggablePlayer> _bluePlayers = [];
  List<DraggablePlayer> _redPlayers = [];
  DraggablePlayer? _ball;

  @override
  void initState() {
    super.initState();
    _initializePlayers();
  }

  void _initializePlayers() {
    // Initialize blue players (1-11)
    _bluePlayers = List.generate(11, (index) {
      return DraggablePlayer(
        id: 'blue_${index + 1}',
        number: index + 1,
        color: CoachGuruTheme.mainBlue,
        isOnPitch: false,
        position: Offset.zero,
      );
    });

    // Initialize red players (1-11)
    _redPlayers = List.generate(11, (index) {
      return DraggablePlayer(
        id: 'red_${index + 1}',
        number: index + 1,
        color: CoachGuruTheme.errorRed,
        isOnPitch: false,
        position: Offset.zero,
      );
    });

    // Initialize ball
    _ball = DraggablePlayer(
      id: 'ball',
      number: 0,
      color: CoachGuruTheme.white,
      isOnPitch: false,
      position: Offset.zero,
    );
  }

  void _clearBoard() {
    setState(() {
      // Clear all players from pitch
      _playersOnPitch.clear();

      // Reset all players to not on pitch
      for (var player in _bluePlayers) {
        player.isOnPitch = false;
        player.position = Offset.zero;
      }

      for (var player in _redPlayers) {
        player.isOnPitch = false;
        player.position = Offset.zero;
      }

      // Reset ball
      if (_ball != null) {
        _ball!.isOnPitch = false;
        _ball!.position = Offset.zero;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tactic'),
        backgroundColor: CoachGuruTheme.accentGreen,
        foregroundColor: CoachGuruTheme.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: CoachGuruTheme.accentGreen,
          statusBarIconBrightness: Brightness.light,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearBoard,
            tooltip: 'Clear Board',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Football pitch
          Positioned.fill(child: CustomPaint(painter: FootballPitchPainter())),

          // Players on pitch
          ..._playersOnPitch.map((player) => _buildDraggablePlayer(player)),

          // Bottom dock with available players
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: CoachGuruTheme.softGrey,
                border: Border(
                  top: BorderSide(color: CoachGuruTheme.textLight, width: 1),
                ),
              ),
              child: Column(
                children: [
                  // Blue players
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Blue:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _bluePlayers
                                    .where((p) => !p.isOnPitch)
                                    .map((player) => _buildDockPlayer(player))
                                    .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Red players
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Red:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _redPlayers
                                    .where((p) => !p.isOnPitch)
                                    .map((player) => _buildDockPlayer(player))
                                    .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Ball
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Ball:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          if (_ball != null && !_ball!.isOnPitch)
                            _buildDockPlayer(_ball!),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDockPlayer(DraggablePlayer player) {
    return Draggable<DraggablePlayer>(
      data: player,
      feedback: _buildPlayerChip(player, size: 40),
      childWhenDragging: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: player.color.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
      ),
      onDragEnd: (details) {
        setState(() {
          // Check if dropped on pitch area
          final screenSize = MediaQuery.of(context).size;
          final appBarHeight =
              kToolbarHeight + MediaQuery.of(context).padding.top;
          final pitchTop = appBarHeight;
          final pitchBottom = screenSize.height - 120; // Account for dock

          if (details.offset.dy >= pitchTop &&
              details.offset.dy <= pitchBottom) {
            // Move player to pitch
            player.isOnPitch = true;
            player.position = details.offset;
            _playersOnPitch.add(player);
          }
        });
      },
      child: _buildPlayerChip(player, size: 40),
    );
  }

  Widget _buildDraggablePlayer(DraggablePlayer player) {
    return Positioned(
      left: player.position.dx - 20,
      top: player.position.dy - 20,
      child: Draggable<DraggablePlayer>(
        data: player,
        feedback: _buildPlayerChip(player, size: 44),
        onDragEnd: (details) {
          setState(() {
            // Clamp position to pitch bounds
            final screenSize = MediaQuery.of(context).size;
            final appBarHeight =
                kToolbarHeight + MediaQuery.of(context).padding.top;
            final pitchTop = appBarHeight;
            final pitchBottom = screenSize.height - 120; // Account for dock
            final pitchLeft = 0.0;
            final pitchRight = screenSize.width;

            final clampedX = details.offset.dx.clamp(
              pitchLeft + 20,
              pitchRight - 20,
            );
            final clampedY = details.offset.dy.clamp(
              pitchTop + 20,
              pitchBottom - 20,
            );

            player.position = Offset(clampedX, clampedY);
          });
        },
        child: _buildPlayerChip(player, size: 44),
      ),
    );
  }

  Widget _buildPlayerChip(DraggablePlayer player, {required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: player.color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: CoachGuruTheme.textDark.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: player.id == 'ball'
            ? const Text('⚽', style: TextStyle(fontSize: 20))
            : Text(
                player.number.toString(),
                style: const TextStyle(
                  color: CoachGuruTheme.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}

class DraggablePlayer {
  final String id;
  final int number;
  final Color color;
  bool isOnPitch;
  Offset position;

  DraggablePlayer({
    required this.id,
    required this.number,
    required this.color,
    required this.isOnPitch,
    required this.position,
  });
}

class FootballPitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CoachGuruTheme.accentGreen
      ..style = PaintingStyle.fill;

    // Fill the entire canvas with green
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw pitch lines
    final linePaint = Paint()
      ..color = CoachGuruTheme.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Calculate pitch dimensions (leaving some margin)
    final margin = 20.0;
    final pitchWidth = size.width - (margin * 2);
    final pitchHeight =
        size.height - (margin * 2) - 120; // Account for bottom dock
    final pitchLeft = margin;
    final pitchTop = margin;

    // Outer boundary
    canvas.drawRect(
      Rect.fromLTWH(pitchLeft, pitchTop, pitchWidth, pitchHeight),
      linePaint,
    );

    // Center line (horizontal line dividing the field vertically)
    canvas.drawLine(
      Offset(pitchLeft, pitchTop + pitchHeight / 2),
      Offset(pitchLeft + pitchWidth, pitchTop + pitchHeight / 2),
      linePaint,
    );

    // Center circle
    canvas.drawCircle(
      Offset(pitchLeft + pitchWidth / 2, pitchTop + pitchHeight / 2),
      pitchWidth * 0.15,
      linePaint,
    );

    // Center spot
    canvas.drawCircle(
      Offset(pitchLeft + pitchWidth / 2, pitchTop + pitchHeight / 2),
      3,
      Paint()..color = CoachGuruTheme.white,
    );

    // Top penalty area
    final penaltyAreaWidth = pitchWidth * 0.4;
    final penaltyAreaHeight = pitchHeight * 0.2;
    canvas.drawRect(
      Rect.fromLTWH(
        pitchLeft + (pitchWidth - penaltyAreaWidth) / 2,
        pitchTop,
        penaltyAreaWidth,
        penaltyAreaHeight,
      ),
      linePaint,
    );

    // Top six-yard box
    final sixYardWidth = pitchWidth * 0.25;
    final sixYardHeight = pitchHeight * 0.1;
    canvas.drawRect(
      Rect.fromLTWH(
        pitchLeft + (pitchWidth - sixYardWidth) / 2,
        pitchTop,
        sixYardWidth,
        sixYardHeight,
      ),
      linePaint,
    );

    // Top goal
    canvas.drawRect(
      Rect.fromLTWH(
        pitchLeft + (pitchWidth - pitchWidth * 0.2) / 2,
        pitchTop - 5,
        pitchWidth * 0.2,
        5,
      ),
      linePaint,
    );

    // Bottom penalty area
    canvas.drawRect(
      Rect.fromLTWH(
        pitchLeft + (pitchWidth - penaltyAreaWidth) / 2,
        pitchTop + pitchHeight - penaltyAreaHeight,
        penaltyAreaWidth,
        penaltyAreaHeight,
      ),
      linePaint,
    );

    // Bottom six-yard box
    canvas.drawRect(
      Rect.fromLTWH(
        pitchLeft + (pitchWidth - sixYardWidth) / 2,
        pitchTop + pitchHeight - sixYardHeight,
        sixYardWidth,
        sixYardHeight,
      ),
      linePaint,
    );

    // Bottom goal
    canvas.drawRect(
      Rect.fromLTWH(
        pitchLeft + (pitchWidth - pitchWidth * 0.2) / 2,
        pitchTop + pitchHeight,
        pitchWidth * 0.2,
        5,
      ),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
