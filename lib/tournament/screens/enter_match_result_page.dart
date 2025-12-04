import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';
import '../../utils/navigation_helper.dart';
import '../../models/tournament/tournament_match.dart';
import '../../models/tournament/tournament_data.dart';
import '../services/tournament_local_service.dart';

/// Enter Match Result Page
/// Allows user to enter match result, scorers, and assists
class EnterMatchResultPage extends StatefulWidget {
  final TournamentMatch match;
  final int index;

  const EnterMatchResultPage({
    Key? key,
    required this.match,
    required this.index,
  }) : super(key: key);

  @override
  State<EnterMatchResultPage> createState() => _EnterMatchResultPageState();
}

class _EnterMatchResultPageState extends State<EnterMatchResultPage> {
  final _myGoalsController = TextEditingController();
  final _opponentGoalsController = TextEditingController();
  final List<String?> _scorers = [];
  final List<String?> _assists = [];
  TournamentData? _tournamentData;
  List<String> _myTeamPlayers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTournamentData();
  }

  Future<void> _loadTournamentData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await TournamentLocalService.loadOrCreateDefault();
      if (mounted) {
        setState(() {
          _tournamentData = data;
          // Load MyTeam players from tournament data
          // Source: TournamentData.myTeam.players (connected from Teams screen)
          _myTeamPlayers = List<String>.from(data.myTeam.players);

          // Pre-fill with existing result if available
          if (widget.match.result != null && widget.match.result!.isNotEmpty) {
            final parts = widget.match.result!.split(':');
            if (parts.length == 2) {
              _myGoalsController.text = parts[0].trim();
              _opponentGoalsController.text = parts[1].trim();
            }
          }

          // Pre-fill scorers and assists (only if player exists in MyTeam)
          _scorers.addAll(
            widget.match.scorers
                .where((s) => _myTeamPlayers.contains(s))
                .map((s) => s),
          );
          _assists.addAll(
            widget.match.assists
                .where((a) => _myTeamPlayers.contains(a))
                .map((a) => a),
          );

          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading tournament data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _myGoalsController.dispose();
    _opponentGoalsController.dispose();
    super.dispose();
  }

  void _addScorer() {
    if (_myTeamPlayers.isEmpty) {
      _showNoPlayersDialog();
      return;
    }
    setState(() {
      _scorers.add(null);
    });
  }

  void _removeScorer(int index) {
    setState(() {
      _scorers.removeAt(index);
    });
  }

  void _addAssist() {
    if (_myTeamPlayers.isEmpty) {
      _showNoPlayersDialog();
      return;
    }
    setState(() {
      _assists.add(null);
    });
  }

  void _showNoPlayersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Players Available'),
        content: const Text('Please add MyTeam players first.\n\nGo to Teams screen to select players for your team.'),
        actions: [
          TextButton(
            onPressed: () => NavHelper.safePopDialog(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _removeAssist(int index) {
    setState(() {
      _assists.removeAt(index);
    });
  }

  Future<void> _saveResult() async {
    final myGoalsText = _myGoalsController.text.trim();
    final opponentGoalsText = _opponentGoalsController.text.trim();

    if (myGoalsText.isEmpty || opponentGoalsText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both scores'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate numeric input
    int myGoals;
    int opponentGoals;
    try {
      myGoals = int.parse(myGoalsText);
      opponentGoals = int.parse(opponentGoalsText);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scores must be numbers'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_tournamentData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Tournament data not loaded'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Filter out null values from scorers and assists
    final scorers = _scorers.where((s) => s != null && s!.isNotEmpty).map((s) => s!).toList();
    final assists = _assists.where((a) => a != null && a!.isNotEmpty).map((a) => a!).toList();

    // Create result string
    final result = '$myGoals:$opponentGoals';

    // Update the match
    final updatedMatch = widget.match.copyWith(
      result: result,
      scorers: scorers,
      assists: assists,
    );

    // Update tournament data
    final updatedMatches = List<TournamentMatch>.from(_tournamentData!.matches);
    if (widget.index < updatedMatches.length) {
      updatedMatches[widget.index] = updatedMatch;
    }

    final updatedData = _tournamentData!.copyWith(matches: updatedMatches);

    // Save to local storage
    final success = await TournamentLocalService.saveTournamentData(updatedData);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Match result saved successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Pop back to previous screen
        NavHelper.safePop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving match result'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Enter Result'),
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: CoachGuruTheme.mainBlue,
              statusBarIconBrightness: Brightness.light,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => NavHelper.safePop(context),
            ),
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Enter Result'),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: CoachGuruTheme.mainBlue,
            statusBarIconBrightness: Brightness.light,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => NavHelper.safePop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Match Info Card
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                shadowColor: CoachGuruTheme.mainBlue.withOpacity(0.18),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'MyTeam vs ${widget.match.opponent}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Result Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Result',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: CoachGuruTheme.textDark,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                shadowColor: CoachGuruTheme.mainBlue.withOpacity(0.18),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _myGoalsController,
                          decoration: const InputDecoration(
                            labelText: 'Goals MyTeam',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _opponentGoalsController,
                          decoration: InputDecoration(
                            labelText: 'Goals ${widget.match.opponent}',
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Goalscorers Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Goalscorers',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: CoachGuruTheme.textDark,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                shadowColor: CoachGuruTheme.mainBlue.withOpacity(0.18),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_myTeamPlayers.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'No players in MyTeam. Add players in Teams screen first.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: CoachGuruTheme.textLight,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        )
                      else ...[
                        ..._scorers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final selectedPlayer = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selectedPlayer,
                                    decoration: const InputDecoration(
                                      labelText: 'Select Scorer',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: _myTeamPlayers.map((player) {
                                      return DropdownMenuItem<String>(
                                        value: player,
                                        child: Text(player),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _scorers[index] = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeScorer(index),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _myTeamPlayers.isEmpty ? null : _addScorer,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Scorer'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: CoachGuruTheme.mainBlue,
                              side: BorderSide(color: CoachGuruTheme.mainBlue),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Assists Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Assists',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: CoachGuruTheme.textDark,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                shadowColor: CoachGuruTheme.mainBlue.withOpacity(0.18),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_myTeamPlayers.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'No players in MyTeam. Add players in Teams screen first.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: CoachGuruTheme.textLight,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        )
                      else ...[
                        ..._assists.asMap().entries.map((entry) {
                          final index = entry.key;
                          final selectedPlayer = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: selectedPlayer,
                                    decoration: const InputDecoration(
                                      labelText: 'Select Assist Provider',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: _myTeamPlayers.map((player) {
                                      return DropdownMenuItem<String>(
                                        value: player,
                                        child: Text(player),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _assists[index] = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeAssist(index),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _myTeamPlayers.isEmpty ? null : _addAssist,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Assist'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: CoachGuruTheme.mainBlue,
                              side: BorderSide(color: CoachGuruTheme.mainBlue),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveResult,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CoachGuruTheme.mainBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

