import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';
import '../../utils/navigation_helper.dart';
import '../../models/tournament/tournament_match.dart';

/// Enter Match Result Screen
/// Allows user to enter match result, scorers, and assists
class EnterMatchResultScreen extends StatefulWidget {
  final TournamentMatch match;
  final int index;

  const EnterMatchResultScreen({
    Key? key,
    required this.match,
    required this.index,
  }) : super(key: key);

  @override
  State<EnterMatchResultScreen> createState() => _EnterMatchResultScreenState();
}

class _EnterMatchResultScreenState extends State<EnterMatchResultScreen> {
  final _myGoalsController = TextEditingController();
  final _opponentGoalsController = TextEditingController();
  final List<String> _scorers = [];
  final List<String> _assists = [];

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing result if available
    if (widget.match.result != null && widget.match.result!.isNotEmpty) {
      final parts = widget.match.result!.split(':');
      if (parts.length == 2) {
        _myGoalsController.text = parts[0].trim();
        _opponentGoalsController.text = parts[1].trim();
      }
    }
    _scorers.addAll(widget.match.scorers);
    _assists.addAll(widget.match.assists);
  }

  @override
  void dispose() {
    _myGoalsController.dispose();
    _opponentGoalsController.dispose();
    super.dispose();
  }

  void _addScorer() {
    // TODO: Implement player selection dialog
    // For now, show a simple text input
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Scorer'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Player Name',
            hintText: 'Enter scorer name',
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
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _scorers.add(name);
                });
                NavHelper.safePopDialog(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addAssist() {
    // TODO: Implement player selection dialog
    // For now, show a simple text input
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Assist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Player Name',
            hintText: 'Enter assist provider name',
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
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _assists.add(name);
                });
                NavHelper.safePopDialog(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeScorer(int index) {
    setState(() {
      _scorers.removeAt(index);
    });
  }

  void _removeAssist(int index) {
    setState(() {
      _assists.removeAt(index);
    });
  }

  void _saveResult() {
    final myGoals = _myGoalsController.text.trim();
    final opponentGoals = _opponentGoalsController.text.trim();

    if (myGoals.isEmpty || opponentGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both scores'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate numeric input
    try {
      int.parse(myGoals);
      int.parse(opponentGoals);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scores must be numbers'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Return result to previous screen
    final result = '$myGoals:$opponentGoals';
    Navigator.of(context).pop({
      'result': result,
      'scorers': _scorers,
      'assists': _assists,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Match ${widget.index + 1} - Enter Result'),
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

              // Score Input Card
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
                      Text(
                        'Score',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _myGoalsController,
                              decoration: const InputDecoration(
                                labelText: 'MyTeam Goals',
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
                                labelText: '${widget.match.opponent} Goals',
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Scorers Card
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Scorers',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addScorer,
                            color: CoachGuruTheme.mainBlue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_scorers.isEmpty)
                        Text(
                          'No scorers added',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: CoachGuruTheme.textLight,
                              ),
                        )
                      else
                        ..._scorers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final scorer = entry.value;
                          return ListTile(
                            leading: const Icon(Icons.sports_soccer),
                            title: Text(scorer),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeScorer(index),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Assists Card
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Assists',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addAssist,
                            color: CoachGuruTheme.mainBlue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_assists.isEmpty)
                        Text(
                          'No assists added',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: CoachGuruTheme.textLight,
                              ),
                        )
                      else
                        ..._assists.asMap().entries.map((entry) {
                          final index = entry.key;
                          final assist = entry.value;
                          return ListTile(
                            leading: const Icon(Icons.assistant),
                            title: Text(assist),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeAssist(index),
                            ),
                          );
                        }),
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
                    label: const Text('Save Result'),
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

