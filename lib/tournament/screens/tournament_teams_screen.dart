import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/share_button.dart';
import '../../player/player_provider.dart';
import '../../player/player_model.dart';
import '../../models/tournament/tournament_data.dart';
import '../../models/tournament/tournament_team.dart';
import '../services/tournament_local_service.dart';

/// Tournament Teams Screen
/// Manages tournament teams
class TournamentTeamsScreen extends StatefulWidget {
  const TournamentTeamsScreen({Key? key}) : super(key: key);

  @override
  State<TournamentTeamsScreen> createState() => _TournamentTeamsScreenState();
}

class _TournamentTeamsScreenState extends State<TournamentTeamsScreen> {
  TournamentData? _tournamentData;
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

  Future<void> _saveTournamentData() async {
    if (_tournamentData == null) return;

    try {
      await TournamentLocalService.saveTournamentData(_tournamentData!);
    } catch (e) {
      print('Error saving tournament data: $e');
    }
  }

  Future<void> _selectMyTeamPlayers() async {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final allPlayers = playerProvider.players;
    final currentPlayerNames = _tournamentData?.myTeam.players ?? [];

    // Create a set of currently selected player names for quick lookup
    final selectedNames = currentPlayerNames.toSet();

    // Show multi-select dialog
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => _PlayerMultiSelectDialog(
        players: allPlayers,
        selectedNames: selectedNames,
      ),
    );

    // Update state with selected players
    if (result != null && _tournamentData != null) {
      setState(() {
        _tournamentData = _tournamentData!.copyWith(
          myTeam: _tournamentData!.myTeam.copyWith(
            players: List<String>.from(result),
          ),
        );
      });
      // Save to local storage
      await _saveTournamentData();
    }
  }

  Future<void> _addOpponent() async {
    final nameController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Opponent'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Opponent Name',
            hintText: 'Enter opponent team name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => NavHelper.safePopDialog(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(context).pop(name);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && _tournamentData != null) {
      final currentOpponents = _tournamentData!.opponents;

      setState(() {
        final newOpponent = TournamentTeam(
          name: result,
          players: [],
        );
        _tournamentData = _tournamentData!.copyWith(
          opponents: [...currentOpponents, newOpponent],
        );
      });
      await _saveTournamentData();
    }
  }

  Future<void> _removeOpponent(int index) async {
    if (_tournamentData == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Opponent'),
        content: Text(
          'Are you sure you want to remove "${_tournamentData!.opponents[index].name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => NavHelper.safePopDialog(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && _tournamentData != null) {
      setState(() {
        final opponents = List<TournamentTeam>.from(_tournamentData!.opponents);
        opponents.removeAt(index);
        _tournamentData = _tournamentData!.copyWith(opponents: opponents);
      });
      await _saveTournamentData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Teams'),
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

    if (_tournamentData == null) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Teams'),
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
            child: Text('Error loading tournament data'),
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Teams'),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: CoachGuruTheme.mainBlue,
            statusBarIconBrightness: Brightness.light,
          ),
          actions: const [ShareButton()],
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
              // Section 1: MyTeam
              _buildSectionHeader('MyTeam'),
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
                      Row(
                        children: [
                          Icon(
                            Icons.group,
                            color: CoachGuruTheme.mainBlue,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _tournamentData!.myTeam.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: CoachGuruTheme.textDark,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${_tournamentData!.myTeam.players.length} player${_tournamentData!.myTeam.players.length != 1 ? 's' : ''} selected',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: CoachGuruTheme.textLight,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      if (_tournamentData!.myTeam.players.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _tournamentData!.myTeam.players.map((playerName) {
                            return Chip(
                              label: Text(playerName),
                              backgroundColor: CoachGuruTheme.lightBlue,
                              labelStyle: TextStyle(
                                color: CoachGuruTheme.mainBlue,
                                fontSize: 12,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _selectMyTeamPlayers,
                          icon: const Icon(Icons.person_add),
                          label: const Text('Select MyTeam Players'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CoachGuruTheme.mainBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Section 2: Opponents
              _buildSectionHeader('Opponents'),
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _addOpponent,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Opponent'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CoachGuruTheme.accentGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_tournamentData!.opponents.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No opponents added yet',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: CoachGuruTheme.textLight,
                                  ),
                            ),
                          ),
                        )
                      else
                        ..._tournamentData!.opponents.asMap().entries.map((entry) {
                          final index = entry.key;
                          final opponent = entry.value;
                          return _buildOpponentCard(context, opponent, index);
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: CoachGuruTheme.textDark,
            ),
      ),
    );
  }

  Widget _buildOpponentCard(BuildContext context, TournamentTeam opponent, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: CoachGuruTheme.mainBlue,
          child: Text(
            opponent.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          opponent.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _removeOpponent(index),
        ),
      ),
    );
  }
}

/// Multi-select dialog for selecting players
class _PlayerMultiSelectDialog extends StatefulWidget {
  final List<PlayerModel> players;
  final Set<String> selectedNames;

  const _PlayerMultiSelectDialog({
    required this.players,
    required this.selectedNames,
  });

  @override
  State<_PlayerMultiSelectDialog> createState() => _PlayerMultiSelectDialogState();
}

class _PlayerMultiSelectDialogState extends State<_PlayerMultiSelectDialog> {
  late Set<String> _selectedNames;

  @override
  void initState() {
    super.initState();
    _selectedNames = Set<String>.from(widget.selectedNames);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Players'),
      content: SizedBox(
        width: double.maxFinite,
        child: widget.players.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No players available'),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: widget.players.length,
                itemBuilder: (context, index) {
                  final player = widget.players[index];
                  final isSelected = _selectedNames.contains(player.name);

                  return CheckboxListTile(
                    title: Text(player.name),
                    subtitle: player.shirtNumber != null
                        ? Text('No. ${player.shirtNumber} - ${player.position}')
                        : Text(player.position),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedNames.add(player.name);
                        } else {
                          _selectedNames.remove(player.name);
                        }
                      });
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Return selected players as a List<String>
            final selectedList = _selectedNames.toList();
            Navigator.of(context).pop(selectedList);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
