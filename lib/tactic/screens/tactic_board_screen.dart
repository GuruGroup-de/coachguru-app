import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import '../providers/tactic_provider.dart';
import '../models/player_icon.dart';
import '../widgets/player_icon_widget.dart';
import '../widgets/pitch_background.dart';
import '../../theme/theme.dart';
import '../../utils/screenshot_controller.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/share_button.dart';

/// Tactic Board Screen
/// Interactive tactic board with two teams, free dragging, and formation presets
class TacticBoardScreen extends StatefulWidget {
  const TacticBoardScreen({super.key});

  @override
  State<TacticBoardScreen> createState() => _TacticBoardScreenState();
}

class _TacticBoardScreenState extends State<TacticBoardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TacticProvider>();
      provider.loadFormation().then((_) {
        if (provider.blueTeam.isEmpty && provider.redTeam.isEmpty) {
          provider.initializeTeams();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TacticProvider>();
    final blueTeam = provider.blueTeam;
    final redTeam = provider.redTeam;
    final currentFormation = provider.currentFormation;
    final isBlueActive = provider.isBlueTeamActive;

    return WillPopScope(
      onWillPop: () async {
        NavHelper.safePop(context);
        return false;
      },
      child: SafeArea(
        child: Screenshot(
          controller: globalScreenshotController,
          child: Scaffold(
        backgroundColor: CoachGuruTheme.softGrey,
        appBar: AppBar(
          title: Text(
            isBlueActive
                ? 'Tactic Board - Blue Team'
                : 'Tactic Board - Red Team',
          ),
          backgroundColor: CoachGuruTheme.mainBlue,
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: CoachGuruTheme.mainBlue,
            statusBarIconBrightness: Brightness.light,
          ),
          actions: [
            const ShareButton(),
            // Switch Team button
            IconButton(
              icon: Icon(isBlueActive ? Icons.swap_horiz : Icons.swap_horiz),
              tooltip: 'Switch Team',
              onPressed: () {
                provider.switchTeam();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Switched to ${provider.isBlueTeamActive ? 'Blue' : 'Red'} Team',
                    ),
                    duration: const Duration(seconds: 1),
                    backgroundColor: CoachGuruTheme.accentGreen,
                  ),
                );
              },
            ),
            // Save Formation button
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save Formation',
              onPressed: () {
                provider.saveFormation();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Formation saved successfully!'),
                    backgroundColor: CoachGuruTheme.accentGreen,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            // Load Formation button
            IconButton(
              icon: const Icon(Icons.folder_open),
              tooltip: 'Load Formation',
              onPressed: () {
                provider.loadFormation();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Formation loaded successfully!'),
                    backgroundColor: CoachGuruTheme.accentGreen,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            // Reset button
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset Formation',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Reset Formation'),
                    content: const Text(
                      'Are you sure you want to reset to default 4-3-3 formation?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          provider.reset();
                          Navigator.of(context, rootNavigator: true).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Formation reset to 4-3-3'),
                              backgroundColor: CoachGuruTheme.accentGreen,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CoachGuruTheme.errorRed,
                        ),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Safety check: if constraints are invalid, show loading
            if (constraints.maxHeight == 0 || constraints.maxWidth == 0) {
              print(
                '[TacticBoard] Invalid constraints: ${constraints.maxWidth}x${constraints.maxHeight}',
              );
              return const Center(child: CircularProgressIndicator());
            }

            // Safety check: ensure teams are initialized
            if (blueTeam.isEmpty && redTeam.isEmpty) {
              print('[TacticBoard] Teams are empty, initializing...');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                provider.initializeTeams();
              });
              return const Center(child: CircularProgressIndicator());
            }

            try {
              return Stack(
                children: [
                  const PitchBackground(),
                  // Blue team players
                  ...blueTeam.map((player) {
                    // Clamp position to valid percentage bounds
                    final clampedPercentX = player.position.dx.clamp(
                      0.0,
                      100.0,
                    );
                    final clampedPercentY = player.position.dy.clamp(
                      0.0,
                      100.0,
                    );

                    // Convert percentage to pixel coordinates
                    final x = (clampedPercentX / 100) * constraints.maxWidth;
                    final y = (clampedPercentY / 100) * constraints.maxHeight;

                    // Clamp pixel coordinates to container bounds
                    final clampedX = x.clamp(0.0, constraints.maxWidth);
                    final clampedY = y.clamp(0.0, constraints.maxHeight);

                    return PlayerIconWidget(
                      player: PlayerIcon(
                        id: player.id,
                        number: player.number,
                        color: player.color,
                        position: Offset(clampedX, clampedY),
                      ),
                      constraints: constraints,
                      onPositionChanged: (newPosition) {
                        // Clamp new position to container bounds
                        final clampedNewX = newPosition.dx.clamp(
                          0.0,
                          constraints.maxWidth,
                        );
                        final clampedNewY = newPosition.dy.clamp(
                          0.0,
                          constraints.maxHeight,
                        );

                        // Convert back to percentage and clamp to bounds
                        final percentX =
                            ((clampedNewX / constraints.maxWidth) * 100).clamp(
                              0.0,
                              100.0,
                            );
                        final percentY =
                            ((clampedNewY / constraints.maxHeight) * 100).clamp(
                              0.0,
                              100.0,
                            );

                        provider.updatePlayerPosition(
                          player.id,
                          Offset(percentX, percentY),
                          true,
                        );
                      },
                    );
                  }),
                  // Red team players
                  ...redTeam.map((player) {
                    // Clamp position to valid percentage bounds
                    final clampedPercentX = player.position.dx.clamp(
                      0.0,
                      100.0,
                    );
                    final clampedPercentY = player.position.dy.clamp(
                      0.0,
                      100.0,
                    );

                    // Convert percentage to pixel coordinates
                    final x = (clampedPercentX / 100) * constraints.maxWidth;
                    final y = (clampedPercentY / 100) * constraints.maxHeight;

                    // Clamp pixel coordinates to container bounds
                    final clampedX = x.clamp(0.0, constraints.maxWidth);
                    final clampedY = y.clamp(0.0, constraints.maxHeight);

                    return PlayerIconWidget(
                      player: PlayerIcon(
                        id: player.id,
                        number: player.number,
                        color: player.color,
                        position: Offset(clampedX, clampedY),
                      ),
                      constraints: constraints,
                      onPositionChanged: (newPosition) {
                        // Clamp new position to container bounds
                        final clampedNewX = newPosition.dx.clamp(
                          0.0,
                          constraints.maxWidth,
                        );
                        final clampedNewY = newPosition.dy.clamp(
                          0.0,
                          constraints.maxHeight,
                        );

                        // Convert back to percentage and clamp to bounds
                        final percentX =
                            ((clampedNewX / constraints.maxWidth) * 100).clamp(
                              0.0,
                              100.0,
                            );
                        final percentY =
                            ((clampedNewY / constraints.maxHeight) * 100).clamp(
                              0.0,
                              100.0,
                            );

                        provider.updatePlayerPosition(
                          player.id,
                          Offset(percentX, percentY),
                          false,
                        );
                      },
                    );
                  }),
                ],
              );
            } catch (e, stackTrace) {
              print('[TacticBoard] Error building Stack: $e');
              print('[TacticBoard] Stack trace: $stackTrace');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error loading tactic board'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        provider.initializeTeams();
                      },
                      child: const Text('Reset Formation'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.1 * 255).round()),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Formation selector
              Text(
                'Formation Presets',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: CoachGuruTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: provider.availableFormations.map((formation) {
                    final isSelected = formation == currentFormation;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(formation),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            provider.applyFormation(formation);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Formation changed to $formation',
                                ),
                                duration: const Duration(seconds: 1),
                                backgroundColor: CoachGuruTheme.accentGreen,
                              ),
                            );
                          }
                        },
                        selectedColor: CoachGuruTheme.mainBlue,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : CoachGuruTheme.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              // Team indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isBlueActive ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Blue Team',
                    style: TextStyle(
                      fontSize: 12,
                      color: isBlueActive
                          ? CoachGuruTheme.mainBlue
                          : CoachGuruTheme.textLight,
                      fontWeight: isBlueActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: !isBlueActive
                            ? Colors.white
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Red Team',
                    style: TextStyle(
                      fontSize: 12,
                      color: !isBlueActive
                          ? CoachGuruTheme.errorRed
                          : CoachGuruTheme.textLight,
                      fontWeight: !isBlueActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
          ),
        ),
      ),
    );
  }
}
