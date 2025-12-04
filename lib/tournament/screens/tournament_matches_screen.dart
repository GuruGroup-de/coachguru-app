import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../theme/theme.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/share_button.dart';
import '../../models/tournament/tournament_data.dart';
import '../../models/tournament/tournament_match.dart';
import '../services/tournament_local_service.dart';
import 'enter_match_result_page.dart';

/// Tournament Matches Screen
/// Manages tournament matches and displays statistics
class TournamentMatchesScreen extends StatefulWidget {
  const TournamentMatchesScreen({Key? key}) : super(key: key);

  @override
  State<TournamentMatchesScreen> createState() => _TournamentMatchesScreenState();
}

class _TournamentMatchesScreenState extends State<TournamentMatchesScreen> {
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

  /// Parse result string "3:1" to (myGoals, opponentGoals)
  (int, int) _parseResult(String? result) {
    if (result == null || result.isEmpty) return (0, 0);
    final parts = result.split(':');
    if (parts.length != 2) return (0, 0);
    try {
      return (int.parse(parts[0].trim()), int.parse(parts[1].trim()));
    } catch (e) {
      return (0, 0);
    }
  }

  /// Calculate points from result (3-1-0 system)
  int _calculatePoints(String? result) {
    final (myGoals, opponentGoals) = _parseResult(result);
    if (myGoals > opponentGoals) return 3; // Win
    if (myGoals == opponentGoals) return 1; // Draw
    return 0; // Loss
  }

  /// Calculate goalscorer ranking
  Map<String, int> _calculateGoalscorerRanking() {
    final ranking = <String, int>{};
    if (_tournamentData == null) return ranking;

    for (final match in _tournamentData!.matches) {
      for (final scorer in match.scorers) {
        ranking[scorer] = (ranking[scorer] ?? 0) + 1;
      }
    }
    return ranking;
  }

  /// Calculate assist ranking
  Map<String, int> _calculateAssistRanking() {
    final ranking = <String, int>{};
    if (_tournamentData == null) return ranking;

    for (final match in _tournamentData!.matches) {
      for (final assist in match.assists) {
        ranking[assist] = (ranking[assist] ?? 0) + 1;
      }
    }
    return ranking;
  }

  /// Calculate MVP ranking (goals + assists)
  Map<String, int> _calculateMVPRanking() {
    final goalscorers = _calculateGoalscorerRanking();
    final assists = _calculateAssistRanking();
    final mvp = <String, int>{};

    // Add goals
    goalscorers.forEach((player, goals) {
      mvp[player] = (mvp[player] ?? 0) + goals;
    });

    // Add assists
    assists.forEach((player, assistCount) {
      mvp[player] = (mvp[player] ?? 0) + assistCount;
    });

    return mvp;
  }

  /// Calculate matches played
  /// Counts only matches with a result entered
  int _calculateMatchesPlayed() {
    if (_tournamentData == null) return 0;
    return _tournamentData!.matches.where((m) => m.result != null && m.result!.isNotEmpty).length;
  }

  /// Calculate goals for and against
  /// Sums goals from all matches with results
  (int, int) _calculateGoalsForAgainst() {
    int goalsFor = 0;
    int goalsAgainst = 0;

    if (_tournamentData == null) return (goalsFor, goalsAgainst);

    for (final match in _tournamentData!.matches) {
      if (match.result != null && match.result!.isNotEmpty) {
        final (myGoals, opponentGoals) = _parseResult(match.result);
        goalsFor += myGoals;
        goalsAgainst += opponentGoals;
      }
    }

    return (goalsFor, goalsAgainst);
  }

  /// Calculate total points
  /// Win = 3 points, Draw = 1 point, Loss = 0 points
  int _calculateTotalPoints() {
    if (_tournamentData == null) return 0;
    int total = 0;
    for (final match in _tournamentData!.matches) {
      if (match.result != null && match.result!.isNotEmpty) {
        total += _calculatePoints(match.result);
      }
    }
    return total;
  }

  /// Calculate table ranking (MyTeam vs opponents)
  /// Sorted by: Points (descending) → Goal Difference (descending) → Goals Scored (descending)
  List<TableEntry> _calculateTableRanking() {
    final table = <TableEntry>[];

    if (_tournamentData == null) return table;

    // Calculate MyTeam stats
    int myTeamPoints = 0;
    int myTeamGoalsFor = 0;
    int myTeamGoalsAgainst = 0;

    for (final match in _tournamentData!.matches) {
      if (match.result != null && match.result!.isNotEmpty) {
        final (myGoals, opponentGoals) = _parseResult(match.result);
        // After saving a match result:
        // matchesPlayed += 1 (handled by _calculateMatchesPlayed)
        // goalsFor += match.goalsFor
        myTeamGoalsFor += myGoals;
        // goalsAgainst += match.goalsAgainst
        myTeamGoalsAgainst += opponentGoals;
        // Points: Win = +3, Draw = +1, Loss = 0
        myTeamPoints += _calculatePoints(match.result);
      }
    }

    table.add(TableEntry(
      teamName: _tournamentData!.myTeam.name,
      points: myTeamPoints,
      goalsFor: myTeamGoalsFor,
      goalsAgainst: myTeamGoalsAgainst,
    ));

    // Calculate opponent stats
    for (final opponent in _tournamentData!.opponents) {
      int opponentPoints = 0;
      int opponentGoalsFor = 0;
      int opponentGoalsAgainst = 0;

      // Find matches against this opponent
      for (final match in _tournamentData!.matches) {
        if (match.opponent == opponent.name &&
            match.result != null &&
            match.result!.isNotEmpty) {
          final (myGoals, oppGoals) = _parseResult(match.result);
          // For opponent: swap the goals
          opponentGoalsFor += oppGoals;
          opponentGoalsAgainst += myGoals;
          // Points: Win = +3, Draw = +1, Loss = 0
          if (oppGoals > myGoals) {
            opponentPoints += 3; // Win
          } else if (oppGoals == myGoals) {
            opponentPoints += 1; // Draw
          }
          // Loss = 0 points (already default)
        }
      }

      table.add(TableEntry(
        teamName: opponent.name,
        points: opponentPoints,
        goalsFor: opponentGoalsFor,
        goalsAgainst: opponentGoalsAgainst,
      ));
    }

    // Recalculate standings by: Points → Goal Difference → Goals Scored
    table.sort((a, b) {
      // 1. Sort by points (descending)
      final pointDiff = b.points.compareTo(a.points);
      if (pointDiff != 0) return pointDiff;

      // 2. Sort by goal difference (descending)
      final aGoalDiff = a.goalsFor - a.goalsAgainst;
      final bGoalDiff = b.goalsFor - b.goalsAgainst;
      final goalDiffDiff = bGoalDiff.compareTo(aGoalDiff);
      if (goalDiffDiff != 0) return goalDiffDiff;

      // 3. Sort by goals scored (descending)
      return b.goalsFor.compareTo(a.goalsFor);
    });

    return table;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Matches & Stats'),
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
            title: const Text('Matches & Stats'),
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

    final matches = _tournamentData!.matches;
    final matchesPlayed = _calculateMatchesPlayed();
    final (goalsFor, goalsAgainst) = _calculateGoalsForAgainst();
    final totalPoints = _calculateTotalPoints();
    final goalscorerRanking = _calculateGoalscorerRanking();
    final assistRanking = _calculateAssistRanking();
    final mvpRanking = _calculateMVPRanking();
    final tableRanking = _calculateTableRanking();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Matches & Stats'),
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
              // Matches Section
              if (matches.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Matches',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: CoachGuruTheme.textDark,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                ...matches.asMap().entries.map((entry) {
                  final index = entry.key;
                  final match = entry.value;
                  return _buildMatchCard(context, match, index);
                }),
                const SizedBox(height: 24),
              ],

              // Stats Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Statistics',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: CoachGuruTheme.textDark,
                      ),
                ),
              ),
              const SizedBox(height: 12),

              // Overall Stats Card
              _buildStatsCard(
                context,
                title: 'Overall Statistics',
                child: Column(
                  children: [
                    _buildStatRow('Matches Played', matchesPlayed.toString()),
                    _buildStatRow('Goals For', goalsFor.toString()),
                    _buildStatRow('Goals Against', goalsAgainst.toString()),
                    _buildStatRow('Goal Difference', (goalsFor - goalsAgainst).toString()),
                    _buildStatRow('Total Points', totalPoints.toString()),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Goalscorer Ranking Card
              if (goalscorerRanking.isNotEmpty)
                _buildStatsCard(
                  context,
                  title: 'Goalscorer Ranking',
                  child: Column(
                    children: (() {
                      final sorted = goalscorerRanking.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));
                      return sorted.take(5).toList().asMap().entries.map((entry) {
                        final index = entry.key;
                        final player = entry.value.key;
                        final goals = entry.value.value;
                        return _buildRankingRow(
                          context,
                          position: index + 1,
                          name: player,
                          value: goals.toString(),
                          icon: Icons.sports_soccer,
                        );
                      }).toList();
                    })(),
                  ),
                ),

              if (goalscorerRanking.isNotEmpty) const SizedBox(height: 12),

              // Assist Ranking Card
              if (assistRanking.isNotEmpty)
                _buildStatsCard(
                  context,
                  title: 'Assist Ranking',
                  child: Column(
                    children: (() {
                      final sorted = assistRanking.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));
                      return sorted.take(5).toList().asMap().entries.map((entry) {
                        final index = entry.key;
                        final player = entry.value.key;
                        final assists = entry.value.value;
                        return _buildRankingRow(
                          context,
                          position: index + 1,
                          name: player,
                          value: assists.toString(),
                          icon: Icons.assistant,
                        );
                      }).toList();
                    })(),
                  ),
                ),

              if (assistRanking.isNotEmpty) const SizedBox(height: 12),

              // MVP Ranking Card
              if (mvpRanking.isNotEmpty)
                _buildStatsCard(
                  context,
                  title: 'MVP Ranking',
                  child: Column(
                    children: (() {
                      final sorted = mvpRanking.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));
                      return sorted.take(5).toList().asMap().entries.map((entry) {
                        final index = entry.key;
                        final player = entry.value.key;
                        final points = entry.value.value;
                        return _buildRankingRow(
                          context,
                          position: index + 1,
                          name: player,
                          value: points.toString(),
                          icon: Icons.emoji_events,
                        );
                      }).toList();
                    })(),
                  ),
                ),

              if (mvpRanking.isNotEmpty) const SizedBox(height: 12),

              // Table Ranking Card
              if (tableRanking.isNotEmpty)
                _buildStatsCard(
                  context,
                  title: 'Table Ranking',
                  child: Column(
                    children: tableRanking.asMap().entries.map((entry) {
                      final index = entry.key;
                      final team = entry.value;
                      return _buildTableRow(
                        context,
                        position: index + 1,
                        teamName: team.teamName,
                        points: team.points,
                        goalsFor: team.goalsFor,
                        goalsAgainst: team.goalsAgainst,
                        isMyTeam: team.teamName == _tournamentData!.myTeam.name,
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, TournamentMatch match, int index) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');
    final (myGoals, opponentGoals) = _parseResult(match.result);

    return Card(
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: CoachGuruTheme.mainBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Match ${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  dateFormat.format(match.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: CoachGuruTheme.textLight,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'MyTeam',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (match.result != null && match.result!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: CoachGuruTheme.lightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$myGoals : $opponentGoals',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: CoachGuruTheme.mainBlue,
                          ),
                    ),
                  )
                else
                  Text(
                    'vs',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: CoachGuruTheme.textLight,
                        ),
                  ),
                Expanded(
                  child: Text(
                    match.opponent,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            if (match.scorers.isNotEmpty || match.assists.isNotEmpty) ...[
              const SizedBox(height: 12),
              if (match.scorers.isNotEmpty)
                Text(
                  'Scorers: ${match.scorers.join(", ")}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: CoachGuruTheme.textLight,
                      ),
                ),
              if (match.assists.isNotEmpty)
                Text(
                  'Assists: ${match.assists.join(", ")}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: CoachGuruTheme.textLight,
                      ),
                ),
            ],
            const SizedBox(height: 12),
            // Enter Result Button - aligned bottom-right
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToEnterResult(match, index),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Enter Result'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CoachGuruTheme.mainBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToEnterResult(TournamentMatch match, int index) async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EnterMatchResultPage(match: match, index: index),
        ),
      );

      // Reload tournament data after returning from result page
      // (the page saves automatically, so we just need to refresh)
      await _loadTournamentData();
    } catch (e) {
      print('Navigation error: $e');
    }
  }

  Widget _buildStatsCard(BuildContext context, {required String title, required Widget child}) {
    return Card(
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
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: CoachGuruTheme.textDark,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CoachGuruTheme.textLight,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: CoachGuruTheme.textDark,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingRow(
    BuildContext context, {
    required int position,
    required String name,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: position == 1
                  ? Colors.amber
                  : CoachGuruTheme.lightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                position.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: position == 1 ? Colors.white : CoachGuruTheme.mainBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: CoachGuruTheme.mainBlue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: CoachGuruTheme.mainBlue,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context, {
    required int position,
    required String teamName,
    required int points,
    required int goalsFor,
    required int goalsAgainst,
    required bool isMyTeam,
  }) {
    final goalDiff = goalsFor - goalsAgainst;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: position == 1
                  ? Colors.amber
                  : isMyTeam
                      ? CoachGuruTheme.mainBlue
                      : CoachGuruTheme.lightBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                position.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: position == 1 || isMyTeam ? Colors.white : CoachGuruTheme.mainBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              teamName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isMyTeam ? FontWeight.bold : FontWeight.w600,
                    color: isMyTeam ? CoachGuruTheme.mainBlue : CoachGuruTheme.textDark,
                  ),
            ),
          ),
          Text(
            '$goalsFor:$goalsAgainst',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CoachGuruTheme.textLight,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            goalDiff >= 0 ? '+$goalDiff' : goalDiff.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: CoachGuruTheme.textLight,
                ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: CoachGuruTheme.accentGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              points.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Table entry for ranking
class TableEntry {
  final String teamName;
  final int points;
  final int goalsFor;
  final int goalsAgainst;

  TableEntry({
    required this.teamName,
    required this.points,
    required this.goalsFor,
    required this.goalsAgainst,
  });
}
