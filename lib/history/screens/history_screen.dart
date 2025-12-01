import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import '../providers/match_provider.dart';
import '../widgets/match_card.dart';
import 'add_match_screen.dart';
import 'match_details_screen.dart';
import '../../theme/theme.dart';
import '../../utils/screenshot_controller.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/share_button.dart';

/// History Screen
/// Displays all match history with modern UI
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchProvider>().loadMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchProvider>();

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
              title: const Text('Match History'),
              backgroundColor: CoachGuruTheme.mainBlue,
              foregroundColor: Colors.white,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: CoachGuruTheme.mainBlue,
                statusBarIconBrightness: Brightness.light,
              ),
              actions: const [ShareButton()],
            ),
            body: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.matches.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sports_soccer,
                          size: 80,
                          color: CoachGuruTheme.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No matches yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: CoachGuruTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add your first match',
                          style: TextStyle(
                            fontSize: 14,
                            color: CoachGuruTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: provider.matches.length,
                    itemBuilder: (context, index) {
                      final match = provider.matches[index];
                      return MatchCard(
                        match: match,
                        onTap: () {
                          try {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MatchDetailsScreen(match: match),
                              ),
                            );
                          } catch (e) {
                            print('Navigation error: $e');
                          }
                        },
                      );
                    },
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                try {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddMatchScreen()),
                  );
                } catch (e) {
                  print('Navigation error: $e');
                }
              },
              backgroundColor: CoachGuruTheme.mainBlue,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }
}
