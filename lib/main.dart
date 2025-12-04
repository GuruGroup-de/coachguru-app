import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'theme/theme.dart';
import 'providers/scouting_provider.dart';
import 'history/history_list_screen.dart';
import 'tournament/screens/tournament_screen.dart';
import 'video/providers/video_analysis_provider.dart';
import 'video/screens/video_import_screen.dart';
import 'player/player_provider.dart';
import 'player/player_model.dart';
import 'player/player_profile_screen.dart';
import 'scouting/screens/add_scouting_report_screen.dart';
import 'training/training_squad_screen.dart';
import 'training/providers/training_attendance_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'utils/screenshot_controller.dart';
import 'utils/share_helper.dart';
import 'utils/navigation_helper.dart';
import 'widgets/share_button.dart';

// Simple singleton to manage team data across screens
class TeamDataManager {
  static final TeamDataManager _instance = TeamDataManager._internal();
  factory TeamDataManager() => _instance;
  TeamDataManager._internal();

  List<Map<String, dynamic>> _players = [
    {
      'id': '1',
      'name': 'John Doe',
      'shirtNumber': 10,
      'assignment': 'NA',
      'createdAt': DateTime.now().millisecondsSinceEpoch - 5000,
    },
    {
      'id': '2',
      'name': 'Mike Smith',
      'shirtNumber': 7,
      'assignment': 'NA',
      'createdAt': DateTime.now().millisecondsSinceEpoch - 4000,
    },
    {
      'id': '3',
      'name': 'Alex Johnson',
      'shirtNumber': 9,
      'assignment': 'NA',
      'createdAt': DateTime.now().millisecondsSinceEpoch - 3000,
    },
    {
      'id': '4',
      'name': 'Tom Wilson',
      'shirtNumber': 5,
      'assignment': 'NA',
      'createdAt': DateTime.now().millisecondsSinceEpoch - 2000,
    },
    {
      'id': '5',
      'name': 'Sam Brown',
      'shirtNumber': 3,
      'assignment': 'NA',
      'createdAt': DateTime.now().millisecondsSinceEpoch - 1000,
    },
  ];

  // Load data from SharedPreferences
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final playersJson = prefs.getString('team_players');
    if (playersJson != null) {
      final List<dynamic> playersList = json.decode(playersJson);
      _players = playersList
          .map((player) => Map<String, dynamic>.from(player))
          .toList();
    }
  }

  // Save data to SharedPreferences
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final playersJson = json.encode(_players);
    await prefs.setString('team_players', playersJson);
  }

  List<Map<String, dynamic>> get players {
    // Sort by shirt number, then by creation date
    final sortedPlayers = List<Map<String, dynamic>>.from(_players);
    sortedPlayers.sort((a, b) {
      final shirtCompare = (a['shirtNumber'] as int).compareTo(
        b['shirtNumber'] as int,
      );
      if (shirtCompare != 0) return shirtCompare;
      return (a['createdAt'] ?? 0).compareTo(b['createdAt'] ?? 0);
    });
    return sortedPlayers;
  }

  void addPlayer(Map<String, dynamic> player) {
    _players.add(player);
    saveData();
  }

  void removePlayer(String playerId) {
    _players.removeWhere((p) => p['id'] == playerId);
    saveData();
  }

  void updatePlayerAssignment(String playerId, String assignment) {
    final playerIndex = _players.indexWhere((p) => p['id'] == playerId);
    if (playerIndex != -1) {
      _players[playerIndex]['assignment'] = assignment;
      saveData();
    }
  }

  List<Map<String, dynamic>> getTeam1Players() {
    return _players.where((p) => p['assignment'] == 'TEAM1').toList();
  }

  List<Map<String, dynamic>> getTeam2Players() {
    return _players.where((p) => p['assignment'] == 'TEAM2').toList();
  }
}

// Scouting Report Provider
class ScoutingReportProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  List<Map<String, dynamic>> get reports => _reports;
  bool get isLoading => _isLoading;

  Future<void> loadReports() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final reportsJson = prefs.getString('scouting_reports');
    if (reportsJson != null) {
      final List<dynamic> decoded = json.decode(reportsJson);
      _reports = decoded
          .map((report) => Map<String, dynamic>.from(report))
          .toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveReports() async {
    final prefs = await SharedPreferences.getInstance();
    final reportsJson = json.encode(_reports);
    await prefs.setString('scouting_reports', reportsJson);
  }

  void addReport(Map<String, dynamic> report) {
    _reports.add(report);
    saveReports();
    notifyListeners();
  }

  void updateReport(String reportId, Map<String, dynamic> updatedReport) {
    final index = _reports.indexWhere((r) => r['id'] == reportId);
    if (index != -1) {
      _reports[index] = updatedReport;
      saveReports();
      notifyListeners();
    }
  }

  void deleteReport(String reportId) {
    _reports.removeWhere((r) => r['id'] == reportId);
    saveReports();
    notifyListeners();
  }

  Map<String, dynamic>? getReport(String reportId) {
    try {
      return _reports.firstWhere((r) => r['id'] == reportId);
    } catch (e) {
      return null;
    }
  }
}

// Calendar Provider for Training
class TrainingCalendarProvider extends ChangeNotifier {
  Map<String, Map<String, dynamic>> _notes = {};
  bool _isLoading = true;

  Map<String, Map<String, dynamic>> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString('training_notes');
    if (notesJson != null) {
      final Map<String, dynamic> decoded = json.decode(notesJson);
      _notes = decoded.map(
        (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveNote(String date, String content) async {
    _notes[date] = {
      'date': date,
      'content': content,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('training_notes', json.encode(_notes));
  }

  Future<void> deleteNote(String date) async {
    _notes.remove(date);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('training_notes', json.encode(_notes));
  }

  String? getNote(String date) {
    return _notes[date]?['content'];
  }

  bool hasNote(String date) {
    return _notes.containsKey(date) &&
        _notes[date]!['content'].toString().isNotEmpty;
  }
}

// Calendar Provider for Program
class ProgramCalendarProvider extends ChangeNotifier {
  Map<String, Map<String, dynamic>> _notes = {};
  bool _isLoading = true;

  Map<String, Map<String, dynamic>> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString('program_notes');
    if (notesJson != null) {
      final Map<String, dynamic> decoded = json.decode(notesJson);
      _notes = decoded.map(
        (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveNote(String date, String content) async {
    _notes[date] = {
      'date': date,
      'content': content,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('program_notes', json.encode(_notes));
  }

  Future<void> deleteNote(String date) async {
    _notes.remove(date);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('program_notes', json.encode(_notes));
  }

  String? getNote(String date) {
    return _notes[date]?['content'];
  }

  bool hasNote(String date) {
    return _notes.containsKey(date) &&
        _notes[date]!['content'].toString().isNotEmpty;
  }
}

void main() {
  // Global error handler for Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print("Flutter Error: ${details.exception}");
    if (details.stack != null) {
      print("Stack trace: ${details.stack}");
    }
  };

  // Global error handler for async errors outside Flutter framework
  runZonedGuarded(
    () {
      runApp(MyApp());
    },
    (error, stack) {
      print("Zoned Error: $error");
      print("Stack trace: $stack");
    },
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TrainingCalendarProvider()),
        ChangeNotifierProvider(create: (_) => ProgramCalendarProvider()),
        ChangeNotifierProvider(create: (_) => ScoutingReportProvider()),
        ChangeNotifierProvider(create: (_) => ScoutingProvider()..loadNotes()),
        ChangeNotifierProvider(create: (_) => VideoAnalysisProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()..loadPlayers()),
        ChangeNotifierProvider(
          create: (_) => TrainingAttendanceProvider()..loadAttendance(),
        ),
      ],
      child: MaterialApp(
        title: 'CoachGuru',
        theme: coachGuruTheme.copyWith(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        home: MainScreen(),
        routes: {'/video-analysis': (context) => const VideoImportScreen()},
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (_) => HomeScreen());
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isNavigating = false;

  final List<Widget> _screens = [
    HomeScreen(),
    TeamScreen(),
    TrainingScreen(),
    ProgramScreen(),
    ScoutingScreen(),
    HistoryListScreen(),
  ];

  // Map of index to route names (none needed - all direct navigation)
  final Map<int, String?> _indexToRoute = {
    0: null, // Home - no route
    1: null, // Team - no route
    2: null, // Training - no route
    3: null, // Program - no route
    4: null, // Scouting - no route
    5: null, // History - direct navigation
  };

  void _handleNavigation(int index) {
    try {
      // Prevent double-navigation
      if (_isNavigating) {
        print('Navigation already in progress, ignoring tap');
        return;
      }

      // Check if tapping the same index
      if (_selectedIndex == index) {
        print('Same index tapped, ignoring');
        return;
      }

      // Check if index is valid
      if (index < 0 || index >= _screens.length) {
        print('Invalid navigation index: $index');
        return;
      }

      // Check if screen widget is valid
      if (_screens[index] == null) {
        print('Screen at index $index is null');
        return;
      }

      _isNavigating = true;

      // Direct navigation for all screens
      final routeName = _indexToRoute[index];
      if (routeName != null) {
        if (!context.mounted) {
          _isNavigating = false;
          return;
        }
        // Update index first for UI consistency
        if (mounted) {
          setState(() {
            _selectedIndex = index;
          });
        }
        NavHelper.safePushNamed(context, routeName).then((_) {
          if (mounted) {
            _isNavigating = false;
          }
        });
        return;
      }

      // For other screens, use index-based navigation
      if (mounted) {
        setState(() {
          _selectedIndex = index;
          _isNavigating = false;
        });
      }
    } catch (e) {
      print('Navigation error: $e');
      if (mounted) {
        _isNavigating = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: globalScreenshotController,
      child: Scaffold(
        body: _buildBody(),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: CoachGuruTheme.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: CoachGuruTheme.textDark.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _handleNavigation,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: CoachGuruTheme.mainBlue,
            unselectedItemColor: CoachGuruTheme.textLight,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.groups_rounded),
                label: 'Team',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center_rounded),
                label: 'Training',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_rounded),
                label: 'Program',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded),
                label: 'Scouting',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded),
                label: 'History',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    // All screens use direct index-based navigation
    final routeName = _indexToRoute[_selectedIndex];
    if (routeName != null) {
      // These screens are handled via routes, show home as fallback
      return HomeScreen();
    }

    // Validate index before accessing screen
    if (_selectedIndex < 0 || _selectedIndex >= _screens.length) {
      return HomeScreen();
    }

    final screen = _screens[_selectedIndex];
    if (screen == null) {
      return HomeScreen();
    }

    return screen;
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('CoachGuru'),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: CoachGuruTheme.mainBlue,
          statusBarIconBrightness: Brightness.light,
        ),
        actions: const [ShareButton()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Blue Profile/Brand Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      CoachGuruTheme.mainBlue,
                      CoachGuruTheme.mainBlue.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: CoachGuruTheme.textDark.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Circular Avatar
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/coachguru_logo.png',
                          fit: BoxFit.contain,
                          width: 58,
                          height: 58,
                          errorBuilder: (context, error, stackTrace) {
                            // Silently handle image loading errors
                            debugPrint('Error loading logo: $error');
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Two Accent Icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: CoachGuruTheme.accentGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.trending_up,
                            color: CoachGuruTheme.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: CoachGuruTheme.accentGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.bar_chart,
                            color: CoachGuruTheme.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      'CoachGuru',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: CoachGuruTheme.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Professional Coaching',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: CoachGuruTheme.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions Section Label
              Text(
                'Quick Actions',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Quick Actions List
              _buildActionCard(
                context,
                icon: Icons.person,
                iconColor: CoachGuruTheme.mainBlue,
                title: 'Player Profiles',
                subtitle: 'View all players',
                onTap: () => _navigateToScreen(context, 1), // TeamScreen index
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                context,
                icon: Icons.bar_chart,
                iconColor: CoachGuruTheme.accentGreen,
                title: 'Match Stats',
                subtitle: 'View match statistics',
                onTap: () =>
                    _navigateToScreen(context, 5), // HistoryScreen index
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                context,
                icon: Icons.group,
                iconColor: CoachGuruTheme.mainBlue,
                title: 'Training Squad',
                subtitle: 'Manage training squad',
                onTap: () {
                  try {
                    NavHelper.safePushWidget(
                      context,
                      const TrainingSquadScreen(),
                    );
                  } catch (e) {
                    print('Navigation error: $e');
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                context,
                icon: Icons.emoji_events,
                iconColor: CoachGuruTheme.accentGreen,
                title: 'Tournament',
                subtitle: 'Manage tournament',
                onTap: () {
                  try {
                    NavHelper.safePushWidget(context, const TournamentScreen());
                  } catch (e) {
                    print('Navigation error: $e');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final heroTag = 'action_card_${title}_${subtitle}';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Hero(
        tag: heroTag,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          shadowColor: CoachGuruTheme.mainBlue.withOpacity(0.18),
          color: CoachGuruTheme.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Hero(
                    tag: '${heroTag}_icon',
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: CoachGuruTheme.lightBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CoachGuruTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: CoachGuruTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: CoachGuruTheme.textLight,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, int index) {
    final mainScreen = context.findAncestorStateOfType<_MainScreenState>();
    if (mainScreen != null) {
      mainScreen.setState(() {
        mainScreen._selectedIndex = index;
      });
    }
  }

  void _navigateToStartMatch(BuildContext context) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StartMatchScreen()),
      );
    } catch (e) {
      print('Navigation error: $e');
    }
  }
}

class TeamScreen extends StatefulWidget {
  @override
  _TeamScreenState createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final TeamDataManager _teamDataManager = TeamDataManager();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _teamDataManager.loadData();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('CoachGuru'),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: CoachGuruTheme.mainBlue,
            statusBarIconBrightness: Brightness.light,
          ),
          actions: const [ShareButton()],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final players = _teamDataManager.players;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CoachGuru'),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: CoachGuruTheme.mainBlue,
          statusBarIconBrightness: Brightness.light,
        ),
        actions: const [ShareButton()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Team Management', style: theme.textTheme.displaySmall),
                FloatingActionButton(
                  onPressed: players.length >= 22 ? null : _showAddPlayerDialog,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          if (players.length >= 22)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Maximum 22 players reached',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: CoachGuruTheme.errorRed,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  shadowColor: CoachGuruTheme.mainBlue.withOpacity(0.18),
                  color: CoachGuruTheme.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tappable player info row
                        GestureDetector(
                          onTap: () =>
                              _navigateToPlayerProfile(context, player),
                          child: Row(
                            children: [
                              // Icon container with light blue background
                              Hero(
                                tag: 'player_avatar_${player['id']}',
                                child: Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: CoachGuruTheme.lightBlue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${player['shirtNumber']}',
                                      style: const TextStyle(
                                        color: CoachGuruTheme.mainBlue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Player name
                              Expanded(
                                child: Text(
                                  player['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: CoachGuruTheme.textDark,
                                  ),
                                ),
                              ),
                              // Delete button
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                color: CoachGuruTheme.errorRed,
                                onPressed: () =>
                                    _showDeleteConfirmation(player),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Assignment Control
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'TEAM1',
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.group, size: 16),
                                  SizedBox(width: 4),
                                  Text('Team 1'),
                                ],
                              ),
                            ),
                            ButtonSegment(
                              value: 'TEAM2',
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.group, size: 16),
                                  SizedBox(width: 4),
                                  Text('Team 2'),
                                ],
                              ),
                            ),
                            ButtonSegment(
                              value: 'BENCH',
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.chair, size: 16),
                                  SizedBox(width: 4),
                                  Text('Bench'),
                                ],
                              ),
                            ),
                            ButtonSegment(value: 'NA', label: Text('N/A')),
                          ],
                          selected: {player['assignment']},
                          onSelectionChanged: (Set<String> selection) {
                            setState(() {
                              _teamDataManager.updatePlayerAssignment(
                                player['id'],
                                selection.first,
                              );
                            });
                          },
                          style: SegmentedButton.styleFrom(
                            selectedBackgroundColor: CoachGuruTheme.accentGreen,
                            selectedForegroundColor: CoachGuruTheme.white,
                            backgroundColor: theme.cardColor,
                            foregroundColor: theme.textTheme.bodyLarge?.color,
                            side: BorderSide(
                              color: theme.dividerColor,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPlayerProfile(
    BuildContext context,
    Map<String, dynamic> playerData,
  ) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);

    // Try to find existing player in PlayerProvider
    PlayerModel? player = playerProvider.getPlayerById(
      playerData['id'] as String,
    );

    // If player doesn't exist in PlayerProvider, create a basic one from team data
    if (player == null) {
      player = PlayerModel(
        id: playerData['id'] as String,
        name: playerData['name'] as String,
        birthYear: 2000, // Default birth year
        position: 'Unknown', // Default position
        strongFoot: 'Right', // Default strong foot
        photoPath: null,
        goals: 0,
        assists: 0,
      );

      // Add to provider if not exists
      playerProvider.addPlayer(player);
    }

    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PlayerProfileScreen(player: player!, provider: playerProvider),
        ),
      );
    } catch (e) {
      print('Navigation error: $e');
    }
  }

  void _showDeleteConfirmation(Map<String, dynamic> player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Player'),
        content: Text('Are you sure you want to delete ${player['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _teamDataManager.removePlayer(player['id']);
              });
              Navigator.of(context, rootNavigator: true).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CoachGuruTheme.errorRed,
              foregroundColor: CoachGuruTheme.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddPlayerDialog() {
    final nameController = TextEditingController();
    final numberController = TextEditingController();
    final birthYearController = TextEditingController();
    String? selectedPosition;
    String? selectedFoot;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Player'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: numberController,
                    decoration: const InputDecoration(
                      labelText: 'T-Shirt Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: birthYearController,
                    decoration: const InputDecoration(
                      labelText: 'Birth Year',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Birth Year is required';
                      }
                      if (value.trim().length != 4) {
                        return 'Birth Year must be 4 digits';
                      }
                      final year = int.tryParse(value.trim());
                      if (year == null || year < 2000 || year > 2020) {
                        return 'Enter a valid year (2000-2020)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Position',
                      border: OutlineInputBorder(),
                    ),
                    items: ['GK', 'DF', 'MF', 'FW']
                        .map(
                          (pos) =>
                              DropdownMenuItem(value: pos, child: Text(pos)),
                        )
                        .toList(),
                    value: selectedPosition,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedPosition = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Position is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Strong Foot',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Left', 'Right', 'Both']
                        .map(
                          (foot) =>
                              DropdownMenuItem(value: foot, child: Text(foot)),
                        )
                        .toList(),
                    value: selectedFoot,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedFoot = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Strong Foot is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final playerId = DateTime.now().millisecondsSinceEpoch
                      .toString();
                  final shirtNumber = int.tryParse(numberController.text);
                  final birthYear = int.parse(birthYearController.text.trim());

                  final playerProvider = Provider.of<PlayerProvider>(
                    context,
                    listen: false,
                  );

                  final newPlayer = PlayerModel(
                    id: playerId,
                    name: nameController.text.trim(),
                    shirtNumber: shirtNumber,
                    birthYear: birthYear,
                    position: selectedPosition!,
                    strongFoot: selectedFoot!,
                  );

                  playerProvider.addPlayer(newPlayer);

                  setState(() {
                    _teamDataManager.addPlayer({
                      'id': playerId,
                      'name': nameController.text.trim(),
                      'shirtNumber': shirtNumber,
                      'assignment': 'NA',
                      'createdAt': DateTime.now().millisecondsSinceEpoch,
                    });
                  });

                  Navigator.of(context, rootNavigator: true).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CoachGuruTheme.mainBlue,
                foregroundColor: CoachGuruTheme.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 3,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgramScreen extends StatefulWidget {
  @override
  _ProgramScreenState createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  DateTime _currentDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgramCalendarProvider>().loadNotes();
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Program'),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: CoachGuruTheme.mainBlue,
          statusBarIconBrightness: Brightness.light,
        ),
        actions: const [ShareButton()],
      ),
      body: Consumer<ProgramCalendarProvider>(
        builder: (context, provider, child) {
          if (!context.mounted) return const SizedBox();
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Month Navigation
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentDate = DateTime(
                            _currentDate.year,
                            _currentDate.month - 1,
                          );
                        });
                      },
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_currentDate),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentDate = DateTime(
                            _currentDate.year,
                            _currentDate.month + 1,
                          );
                        });
                      },
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),

              // Calendar Grid
              Expanded(child: _buildCalendar(provider, theme)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendar(ProgramCalendarProvider provider, ThemeData theme) {
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDayOfMonth = DateTime(
      _currentDate.year,
      _currentDate.month + 1,
      0,
    );
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    // Calculate total cells needed (including empty cells for days before month starts)
    final totalCells = firstDayWeekday - 1 + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: [
        // Weekday headers
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),

        // Calendar grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: rows * 7,
            itemBuilder: (context, index) {
              final dayNumber = index - firstDayWeekday + 2;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return Container(); // Empty cell
              }

              final date = DateTime(
                _currentDate.year,
                _currentDate.month,
                dayNumber,
              );
              final dateString = _formatDate(date);
              final isToday = _formatDate(DateTime.now()) == dateString;
              final isSelected = _formatDate(_selectedDate) == dateString;
              final hasNote = provider.hasNote(dateString);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                  _showNoteDialog(provider, dateString);
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? CoachGuruTheme.mainBlue
                        : isToday
                        ? CoachGuruTheme.accentGreen.withOpacity(0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isToday
                          ? CoachGuruTheme.accentGreen
                          : theme.dividerColor,
                      width: isToday ? 2 : 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          dayNumber.toString(),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isSelected
                                ? CoachGuruTheme.white
                                : theme.textTheme.bodyLarge?.color,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (hasNote)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: CoachGuruTheme.errorRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showNoteDialog(ProgramCalendarProvider provider, String dateString) {
    final existingNote = provider.getNote(dateString) ?? '';
    final controller = TextEditingController(text: existingNote);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat(
                  'EEEE, MMMM d, yyyy',
                ).format(DateTime.parse(dateString)),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (existingNote.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        provider.deleteNote(dateString);
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: CoachGuruTheme.errorRed,
                      ),
                      child: const Text('Delete'),
                    )
                  else
                    const SizedBox(),
                  ElevatedButton(
                    onPressed: () {
                      provider.saveNote(dateString, controller.text);
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrainingScreen extends StatefulWidget {
  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  DateTime _currentDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrainingCalendarProvider>().loadNotes();
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training'),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: CoachGuruTheme.mainBlue,
          statusBarIconBrightness: Brightness.light,
        ),
        actions: const [ShareButton()],
      ),
      body: Consumer<TrainingCalendarProvider>(
        builder: (context, provider, child) {
          if (!context.mounted) return const SizedBox();
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Month Navigation
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentDate = DateTime(
                            _currentDate.year,
                            _currentDate.month - 1,
                          );
                        });
                      },
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_currentDate),
                      style: theme.textTheme.headlineMedium,
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentDate = DateTime(
                            _currentDate.year,
                            _currentDate.month + 1,
                          );
                        });
                      },
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),

              // Calendar Grid
              Expanded(child: _buildCalendar(provider, theme)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendar(TrainingCalendarProvider provider, ThemeData theme) {
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDayOfMonth = DateTime(
      _currentDate.year,
      _currentDate.month + 1,
      0,
    );
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    // Calculate total cells needed (including empty cells for days before month starts)
    final totalCells = firstDayWeekday - 1 + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: [
        // Weekday headers
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),

        // Calendar grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: rows * 7,
            itemBuilder: (context, index) {
              final dayNumber = index - firstDayWeekday + 2;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return Container(); // Empty cell
              }

              final date = DateTime(
                _currentDate.year,
                _currentDate.month,
                dayNumber,
              );
              final dateString = _formatDate(date);
              final isToday = _formatDate(DateTime.now()) == dateString;
              final isSelected = _formatDate(_selectedDate) == dateString;
              final hasNote = provider.hasNote(dateString);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                  _showNoteDialog(provider, dateString);
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? CoachGuruTheme.mainBlue
                        : isToday
                        ? CoachGuruTheme.accentGreen.withOpacity(0.3)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isToday
                          ? CoachGuruTheme.accentGreen
                          : theme.dividerColor,
                      width: isToday ? 2 : 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          dayNumber.toString(),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isSelected
                                ? CoachGuruTheme.white
                                : theme.textTheme.bodyLarge?.color,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (hasNote)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: CoachGuruTheme.errorRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showNoteDialog(TrainingCalendarProvider provider, String dateString) {
    final existingNote = provider.getNote(dateString) ?? '';
    final controller = TextEditingController(text: existingNote);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat(
                  'EEEE, MMMM d, yyyy',
                ).format(DateTime.parse(dateString)),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (existingNote.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        provider.deleteNote(dateString);
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: CoachGuruTheme.errorRed,
                      ),
                      child: const Text('Delete'),
                    )
                  else
                    const SizedBox(),
                  ElevatedButton(
                    onPressed: () {
                      provider.saveNote(dateString, controller.text);
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProgramContent extends StatefulWidget {
  @override
  _ProgramContentState createState() => _ProgramContentState();
}

class _ProgramContentState extends State<ProgramContent> {
  List<Map<String, dynamic>> _fixtures = [];
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _checkAndMovePastFixtures();
    // Check every minute for past fixtures
    Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndMovePastFixtures();
    });
  }

  void _checkAndMovePastFixtures() {
    final now = DateTime.now();
    final fixturesToMove = <Map<String, dynamic>>[];

    for (var fixture in _fixtures) {
      try {
        final dateTime = DateTime.parse(
          '${fixture['date']} ${fixture['time']}',
        );
        // Move to history if match time + 2 hours has passed
        if (now.isAfter(dateTime.add(const Duration(hours: 2)))) {
          fixturesToMove.add(fixture);
        }
      } catch (e) {
        // Skip invalid date formats
      }
    }

    if (fixturesToMove.isNotEmpty) {
      setState(() {
        _fixtures.removeWhere((fixture) => fixturesToMove.contains(fixture));
        _history.addAll(fixturesToMove);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Match Program', style: theme.textTheme.headlineMedium),
              ElevatedButton.icon(
                onPressed: _showAddFixtureDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add Fixture'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CoachGuruTheme.mainBlue,
                  foregroundColor: CoachGuruTheme.white,
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 3,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _fixtures.length,
            itemBuilder: (context, index) {
              final fixture = _fixtures[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                shadowColor: CoachGuruTheme.mainBlue.withOpacity(0.18),
                color: CoachGuruTheme.white,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: CoachGuruTheme.lightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: CoachGuruTheme.mainBlue,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    fixture['opponent'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CoachGuruTheme.textDark,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: ${fixture['date']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: CoachGuruTheme.textLight,
                          ),
                        ),
                        Text(
                          'Time: ${fixture['time']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: CoachGuruTheme.textLight,
                          ),
                        ),
                        Text(
                          'Home/Away: ${fixture['home']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: CoachGuruTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    color: CoachGuruTheme.errorRed,
                    onPressed: () => _showDeleteConfirmation(fixture),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> fixture) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Fixture'),
        content: Text(
          'Are you sure you want to delete ${fixture['opponent']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _fixtures.removeWhere((f) => f['id'] == fixture['id']);
              });
              Navigator.of(context, rootNavigator: true).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CoachGuruTheme.errorRed,
              foregroundColor: CoachGuruTheme.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddFixtureDialog() {
    final opponentController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final homeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Fixture'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: opponentController,
              decoration: const InputDecoration(labelText: 'Opponent'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Time (HH:MM)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: homeController,
              decoration: const InputDecoration(labelText: 'Home/Away'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (opponentController.text.isNotEmpty &&
                  dateController.text.isNotEmpty &&
                  timeController.text.isNotEmpty &&
                  homeController.text.isNotEmpty) {
                setState(() {
                  _fixtures.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'opponent': opponentController.text,
                    'date': dateController.text,
                    'time': timeController.text,
                    'home': homeController.text,
                    'createdAt': DateTime.now(),
                  });
                });
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CoachGuruTheme.mainBlue,
              foregroundColor: CoachGuruTheme.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class StartMatchScreen extends StatefulWidget {
  @override
  _StartMatchScreenState createState() => _StartMatchScreenState();
}

class _StartMatchScreenState extends State<StartMatchScreen>
    with TickerProviderStateMixin {
  final _durationController = TextEditingController(text: '10');
  final _matchesController = TextEditingController(text: '1');
  final _fieldsController = TextEditingController(text: '1');

  String? _durationError;
  String? _matchesError;
  String? _fieldsError;

  final TeamDataManager _teamDataManager = TeamDataManager();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _teamDataManager.loadData();
    final prefs = await SharedPreferences.getInstance();

    // Load saved match parameters
    final savedDuration = prefs.getString('match_duration') ?? '10';
    final savedMatches = prefs.getString('match_matches') ?? '1';
    final savedFields = prefs.getString('match_fields') ?? '1';

    setState(() {
      _durationController.text = savedDuration;
      _matchesController.text = savedMatches;
      _fieldsController.text = savedFields;
      _isLoading = false;
    });
  }

  Future<void> _saveMatchParameters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('match_duration', _durationController.text);
    await prefs.setString('match_matches', _matchesController.text);
    await prefs.setString('match_fields', _fieldsController.text);
  }

  // Match state
  bool _isMatchRunning = false;
  int _currentMatch = 0;
  int _totalMatches = 0;
  int _totalFields = 0;
  int _matchDuration = 0;
  List<Timer> _timers = [];
  List<int> _remainingTimes = [];
  List<bool> _halfTimeReached = [];
  List<Map<String, dynamic>> _matchHistory = [];
  List<Map<String, dynamic>> _substitutions = [];

  @override
  void dispose() {
    // Cancel all timers when widget is disposed
    for (var timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('New Match'),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: CoachGuruTheme.mainBlue,
            statusBarIconBrightness: Brightness.light,
          ),
          actions: const [ShareButton()],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Get current team assignments from TeamDataManager
    final team1Players = _teamDataManager.getTeam1Players();
    final team2Players = _teamDataManager.getTeam2Players();
    final benchPlayers = _teamDataManager.players
        .where((p) => p['assignment'] == 'BENCH')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Match'),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: CoachGuruTheme.mainBlue,
          statusBarIconBrightness: Brightness.light,
        ),
        actions: const [ShareButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match Inputs
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              shadowColor: CoachGuruTheme.mainBlue.withOpacity(0.18),
              color: CoachGuruTheme.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Match Settings',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CoachGuruTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Match Duration
                    TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Match Duration (minutes)',
                        errorText: _durationError,
                      ),
                      onChanged: (value) => _validateDuration(value),
                    ),
                    const SizedBox(height: 16),

                    // Number of Matches
                    TextField(
                      controller: _matchesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Number of Matches',
                        errorText: _matchesError,
                      ),
                      onChanged: (value) => _validateMatches(value),
                    ),
                    const SizedBox(height: 16),

                    // Select Field
                    TextField(
                      controller: _fieldsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Select Field (count)',
                        errorText: _fieldsError,
                      ),
                      onChanged: (value) => _validateFields(value),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Current Lineup
            Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              shadowColor: CoachGuruTheme.mainBlue.withOpacity(0.18),
              color: CoachGuruTheme.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Lineup:',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CoachGuruTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (team1Players.isEmpty &&
                        team2Players.isEmpty &&
                        benchPlayers.isEmpty)
                      Text(
                        'Assign players in Team to populate the lineup.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Team 1 Column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: CoachGuruTheme.errorRed
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Team 1',
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...team1Players
                                        .map(
                                          (player) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 2,
                                            ),
                                            child: Text(
                                              '#${player['shirtNumber']} ${player['name']}',
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Team 2 Column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: CoachGuruTheme.lightBlue,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Team 2',
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...team2Players
                                        .map(
                                          (player) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 2,
                                            ),
                                            child: Text(
                                              '#${player['shirtNumber']} ${player['name']}',
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Bench Column
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: CoachGuruTheme.warningOrange.withOpacity(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bench',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (benchPlayers.isEmpty)
                                  Text(
                                    'No bench players',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  )
                                else
                                  Wrap(
                                    children: benchPlayers
                                        .map(
                                          (player) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 2,
                                            ),
                                            child: Text(
                                              '#${player['shirtNumber']} ${player['name']}',
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Substitutions Display
            if (_substitutions.isNotEmpty) ...[
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                shadowColor: CoachGuruTheme.mainBlue.withOpacity(0.18),
                color: CoachGuruTheme.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Substitutions:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CoachGuruTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_totalFields == 1) ...[
                        // Single field - show all substitutions
                        ..._substitutions
                            .map(
                              (sub) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Text(
                                  '${sub['team']}: ${sub['playerOut']} → ${sub['playerIn']}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            )
                            .toList(),
                      ] else ...[
                        // Multiple fields - group by field
                        ...List.generate(_totalFields, (fieldIndex) {
                          final fieldSubs = _substitutions
                              .where((sub) => sub['field'] == fieldIndex + 1)
                              .toList();
                          if (fieldSubs.isEmpty) return const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Field ${fieldIndex + 1}:',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ...fieldSubs
                                  .map(
                                    (sub) => Padding(
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        top: 2,
                                      ),
                                      child: Text(
                                        '${sub['team']}: ${sub['playerOut']} → ${sub['playerIn']}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              const SizedBox(height: 8),
                            ],
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Match Controls
            if (!_isMatchRunning) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canStartMatch() ? _startMatch : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CoachGuruTheme.mainBlue,
                    foregroundColor: CoachGuruTheme.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 3,
                  ),
                  child: const Text('Start Match'),
                ),
              ),
            ] else ...[
              // Match Timer Display
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                shadowColor: CoachGuruTheme.mainBlue.withOpacity(0.18),
                color: CoachGuruTheme.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Match $_currentMatch of $_totalMatches',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CoachGuruTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_totalFields == 1) ...[
                        // Single field timer
                        Text(
                          _formatTime(_remainingTimes[0]),
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: CoachGuruTheme.errorRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else ...[
                        // Multiple field timers
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(_totalFields, (index) {
                            return Column(
                              children: [
                                Text(
                                  'Field ${index + 1}',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatTime(_remainingTimes[index]),
                                  style: theme.textTheme.headlineLarge
                                      ?.copyWith(
                                        color: CoachGuruTheme.errorRed,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _stopMatch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CoachGuruTheme.errorRed,
                            foregroundColor: CoachGuruTheme.white,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 3,
                          ),
                          child: const Text('Stop Match'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _validateDuration(String value) {
    final duration = int.tryParse(value);
    setState(() {
      if (duration == null || duration < 1 || duration > 45) {
        _durationError = 'Must be between 1-45 minutes';
      } else {
        _durationError = null;
      }
    });
    _saveMatchParameters();
  }

  void _validateMatches(String value) {
    final matches = int.tryParse(value);
    setState(() {
      if (matches == null || matches < 1 || matches > 6) {
        _matchesError = 'Must be between 1-6 matches';
      } else {
        _matchesError = null;
      }
    });
    _saveMatchParameters();
  }

  void _validateFields(String value) {
    final fields = int.tryParse(value);
    setState(() {
      if (fields == null || fields < 1 || fields > 4) {
        _fieldsError = 'Must be between 1-4 fields';
      } else {
        _fieldsError = null;
      }
    });
    _saveMatchParameters();
  }

  bool _canStartMatch() {
    return _durationError == null &&
        _matchesError == null &&
        _fieldsError == null &&
        _durationController.text.isNotEmpty &&
        _matchesController.text.isNotEmpty &&
        _fieldsController.text.isNotEmpty;
  }

  void _startMatch() {
    if (_canStartMatch()) {
      setState(() {
        _isMatchRunning = true;
        _currentMatch = 1;
        _totalMatches = int.parse(_matchesController.text);
        _totalFields = int.parse(_fieldsController.text);
        _matchDuration =
            int.parse(_durationController.text) * 60; // Convert to seconds

        // Initialize timers and states for each field
        _remainingTimes = List.filled(_totalFields, _matchDuration);
        _halfTimeReached = List.filled(_totalFields, false);
        _timers = [];
        _substitutions = [];

        // Start timers for each field
        for (int field = 0; field < _totalFields; field++) {
          _startFieldTimer(field);
        }
      });
    }
  }

  void _startFieldTimer(int fieldIndex) {
    _timers.add(
      Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _remainingTimes[fieldIndex]--;

          // Check for half-time substitution
          if (!_halfTimeReached[fieldIndex] &&
              _remainingTimes[fieldIndex] <= _matchDuration ~/ 2) {
            _halfTimeReached[fieldIndex] = true;
            _performSubstitution(fieldIndex);
          }

          // Check if match is finished
          if (_remainingTimes[fieldIndex] <= 0) {
            timer.cancel();
            _onMatchFinished(fieldIndex);
          }
        });
      }),
    );
  }

  void _performSubstitution(int fieldIndex) {
    // Get bench players
    final benchPlayers = _teamDataManager.players
        .where((p) => p['assignment'] == 'BENCH')
        .toList();
    final team1Players = _teamDataManager.getTeam1Players();
    final team2Players = _teamDataManager.getTeam2Players();

    if (benchPlayers.isNotEmpty) {
      // Move one player from Team 1 to bench and one from bench to Team 1
      if (team1Players.isNotEmpty) {
        final playerToSubOut = team1Players.first;
        final playerToSubIn = benchPlayers.first;

        _teamDataManager.updatePlayerAssignment(playerToSubOut['id'], 'BENCH');
        _teamDataManager.updatePlayerAssignment(playerToSubIn['id'], 'TEAM1');

        // Record substitution
        _substitutions.add({
          'field': fieldIndex + 1,
          'team': 'Team 1',
          'playerOut': playerToSubOut['name'],
          'playerIn': playerToSubIn['name'],
          'time': _formatTime(_remainingTimes[fieldIndex]),
        });
      }

      // Move one player from Team 2 to bench and one from bench to Team 2
      if (team2Players.isNotEmpty && benchPlayers.length > 1) {
        final playerToSubOut = team2Players.first;
        final playerToSubIn = benchPlayers[1];

        _teamDataManager.updatePlayerAssignment(playerToSubOut['id'], 'BENCH');
        _teamDataManager.updatePlayerAssignment(playerToSubIn['id'], 'TEAM2');

        // Record substitution
        _substitutions.add({
          'field': fieldIndex + 1,
          'team': 'Team 2',
          'playerOut': playerToSubOut['name'],
          'playerIn': playerToSubIn['name'],
          'time': _formatTime(_remainingTimes[fieldIndex]),
        });
      }
    }
  }

  void _onMatchFinished(int fieldIndex) {
    // Add match to history
    _matchHistory.add({
      'matchNumber': _currentMatch,
      'field': fieldIndex + 1,
      'duration': _matchDuration,
      'timestamp': DateTime.now(),
      'team1Players': _teamDataManager
          .getTeam1Players()
          .map((p) => p['name'])
          .toList(),
      'team2Players': _teamDataManager
          .getTeam2Players()
          .map((p) => p['name'])
          .toList(),
    });

    // Check if all fields are finished
    bool allFieldsFinished = _remainingTimes.every((time) => time <= 0);

    if (allFieldsFinished) {
      _currentMatch++;

      if (_currentMatch > _totalMatches) {
        // All matches finished
        _finishAllMatches();
      } else {
        // Start next match
        _startNextMatch();
      }
    }
  }

  void _startNextMatch() {
    setState(() {
      _remainingTimes = List.filled(_totalFields, _matchDuration);
      _halfTimeReached = List.filled(_totalFields, false);
      _timers = [];
      _substitutions = [];

      // Start timers for each field
      for (int field = 0; field < _totalFields; field++) {
        _startFieldTimer(field);
      }
    });
  }

  void _finishAllMatches() {
    setState(() {
      _isMatchRunning = false;
      _currentMatch = 0;
    });

    // Cancel all timers
    for (var timer in _timers) {
      timer.cancel();
    }
    _timers.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Matches Finished!'),
        content: Text(
          'Completed $_totalMatches matches. Match history has been saved.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: CoachGuruTheme.mainBlue,
              foregroundColor: CoachGuruTheme.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _stopMatch() {
    setState(() {
      _isMatchRunning = false;
      _currentMatch = 0;
    });

    // Cancel all timers
    for (var timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class ScoutingScreen extends StatefulWidget {
  @override
  _ScoutingScreenState createState() => _ScoutingScreenState();
}

class _ScoutingScreenState extends State<ScoutingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScoutingReportProvider>().loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('CoachGuru'),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: CoachGuruTheme.mainBlue,
          statusBarIconBrightness: Brightness.light,
        ),
        actions: const [ShareButton()],
      ),
      body: Consumer<ScoutingReportProvider>(
        builder: (context, provider, child) {
          if (!context.mounted) return const SizedBox();
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Scouting Reports Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Scouting Reports',
                      style: theme.textTheme.displaySmall,
                    ),
                    // Add New Report Button (green square with +)
                    FloatingActionButton.small(
                      onPressed: _showAddReportDialog,
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),

              // Reports List
              Expanded(child: _buildReportsList(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReportsList(ScoutingReportProvider provider) {
    final theme = Theme.of(context);
    if (provider.reports.isEmpty) {
      return Center(
        child: Text(
          'No scouting reports yet.\n\nTap the + button to add a new report.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: provider.reports.length,
      itemBuilder: (context, index) {
        final report = provider.reports[index];

        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          shadowColor: CoachGuruTheme.mainBlue.withOpacity(0.18),
          color: CoachGuruTheme.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icon container with light blue background
                Hero(
                  tag: 'scouting_avatar_${report['id']}',
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: CoachGuruTheme.lightBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${report['shirtNumber'] ?? '?'}',
                        style: const TextStyle(
                          color: CoachGuruTheme.mainBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Player information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report['playerName'] ?? 'Unknown Player',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CoachGuruTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${report['team'] ?? 'Unknown Team'} • ${report['position'] ?? 'Unknown Position'} • Age ${report['age'] ?? '?'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: CoachGuruTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      color: Theme.of(context).iconTheme.color,
                      onPressed: () => _showReportDetails(report),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: CoachGuruTheme.errorRed,
                      onPressed: () => _showDeleteConfirmation(report),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddReportDialog() {
    NavHelper.safePushWidget(context, const AddScoutingReportScreen());
  }

  void _showReportDetails(Map<String, dynamic> report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report['playerName'] ?? 'Unknown Player',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text('Team: ${report['team'] ?? 'Unknown'}'),
            Text('Position: ${report['position'] ?? 'Unknown'}'),
            Text('Age: ${report['age'] ?? 'Unknown'}'),
            Text('Rating: ${report['rating'] ?? '5.0'}/10'),
            const SizedBox(height: 16),
            Text('Strengths:', style: Theme.of(context).textTheme.titleMedium),
            Text(report['strengths'] ?? ''),
            const SizedBox(height: 8),
            Text('Weaknesses:', style: Theme.of(context).textTheme.titleMedium),
            Text(report['weaknesses'] ?? ''),
            const SizedBox(height: 8),
            Text('Notes:', style: Theme.of(context).textTheme.titleMedium),
            Text(report['notes'] ?? ''),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: Text(
          'Are you sure you want to delete the report for ${report['playerName']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ScoutingReportProvider>().deleteReport(report['id']);
              Navigator.of(context, rootNavigator: true).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CoachGuruTheme.errorRed,
              foregroundColor: CoachGuruTheme.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
