import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/share_button.dart';
import 'tournament_teams_screen.dart';
import 'tournament_schedule_screen.dart';
import 'tournament_matches_screen.dart';

/// Main Tournament Screen
/// Displays tournament overview and navigation to sub-screens
class TournamentScreen extends StatelessWidget {
  const TournamentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tournament'),
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
              // Teams Card
              _buildActionCard(
                context,
                icon: Icons.groups,
                iconColor: CoachGuruTheme.mainBlue,
                title: 'Teams',
                subtitle: 'Manage tournament teams',
                description: 'Select your team players and add up to 3 opponents',
                onTap: () {
                  try {
                    NavHelper.safePushWidget(
                      context,
                      const TournamentTeamsScreen(),
                    );
                  } catch (e) {
                    print('Navigation error: $e');
                  }
                },
              ),
              const SizedBox(height: 12),
              // Schedule Card
              _buildActionCard(
                context,
                icon: Icons.calendar_today,
                iconColor: CoachGuruTheme.accentGreen,
                title: 'Schedule',
                subtitle: 'View tournament schedule',
                description: 'Set date and time for each match in the tournament',
                onTap: () {
                  try {
                    NavHelper.safePushWidget(
                      context,
                      const TournamentScheduleScreen(),
                    );
                  } catch (e) {
                    print('Navigation error: $e');
                  }
                },
              ),
              const SizedBox(height: 12),
              // Matches & Stats Card
              _buildActionCard(
                context,
                icon: Icons.sports_soccer,
                iconColor: CoachGuruTheme.mainBlue,
                title: 'Matches & Stats',
                subtitle: 'Manage tournament matches',
                description: 'Enter match results, view statistics and standings',
                onTap: () {
                  try {
                    NavHelper.safePushWidget(
                      context,
                      const TournamentMatchesScreen(),
                    );
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
    required String description,
    required VoidCallback onTap,
  }) {
    final heroTag = 'tournament_card_${title}_${subtitle}';
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
            child: Container(
              height: 120, // Fixed height for equal card sizes
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Hero(
                    tag: '${heroTag}_icon',
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: CoachGuruTheme.lightBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: iconColor, size: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: CoachGuruTheme.textDark,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: CoachGuruTheme.textLight,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: CoachGuruTheme.textLight,
                                fontSize: 12,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
}
