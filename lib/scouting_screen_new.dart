import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'main.dart';
import 'theme/theme.dart';
import 'utils/screenshot_controller.dart';
import 'utils/navigation_helper.dart';
import 'widgets/share_button.dart';

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
    return WillPopScope(
      onWillPop: () async {
        NavHelper.safePop(context);
        return false;
      },
      child: SafeArea(
        child: Screenshot(
          controller: globalScreenshotController,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('CoachGuru'),
              centerTitle: true,
              backgroundColor: CoachGuruTheme.accentGreen,
              foregroundColor: CoachGuruTheme.textDark,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: CoachGuruTheme.accentGreen,
                statusBarIconBrightness: Brightness.dark,
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => NavHelper.safePop(context),
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
                          const Text(
                            'Scouting Reports',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: CoachGuruTheme.textDark,
                            ),
                          ),
                          // Add New Report Button (green square with +)
                          GestureDetector(
                            onTap: _showAddReportDialog,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: CoachGuruTheme.accentGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: CoachGuruTheme.white,
                                size: 24,
                              ),
                            ),
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
          ),
        ),
      ),
    );
  }

  Widget _buildReportsList(ScoutingReportProvider provider) {
    if (provider.reports.isEmpty) {
      return const Center(
        child: Text(
          'No scouting reports yet.\n\nTap the + button to add a new report.',
          textAlign: TextAlign.center,
          style: TextStyle(color: CoachGuruTheme.textLight),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: provider.reports.length,
      itemBuilder: (context, index) {
        final report = provider.reports[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Blue circular badge with player number
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: CoachGuruTheme.mainBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${report['shirtNumber'] ?? '?'}',
                      style: const TextStyle(
                        color: CoachGuruTheme.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
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
                      icon: Icon(
                        Icons.info_outline,
                        color: CoachGuruTheme.textLight,
                      ),
                      onPressed: () => _showReportDetails(report),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: CoachGuruTheme.errorRed),
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
    final nameController = TextEditingController();
    final teamController = TextEditingController();
    final positionController = TextEditingController();
    final shirtNumberController = TextEditingController();
    final ageController = TextEditingController();
    final notesController = TextEditingController();

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
              const Text(
                'Add Scouting Report',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Player Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: teamController,
                decoration: const InputDecoration(
                  labelText: 'Team',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: positionController,
                decoration: const InputDecoration(
                  labelText: 'Position',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: shirtNumberController,
                decoration: const InputDecoration(
                  labelText: 'T-Shirt Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        final newReport = {
                          'id': DateTime.now().millisecondsSinceEpoch
                              .toString(),
                          'playerName': nameController.text,
                          'team': teamController.text,
                          'position': positionController.text,
                          'shirtNumber':
                              int.tryParse(shirtNumberController.text) ?? 0,
                          'age': int.tryParse(ageController.text) ?? 0,
                          'rating': 5.0,
                          'strengths': '',
                          'weaknesses': '',
                          'notes': notesController.text,
                          'createdAt': DateTime.now().millisecondsSinceEpoch,
                        };

                        context.read<ScoutingReportProvider>().addReport(
                          newReport,
                        );
                        Navigator.of(context, rootNavigator: true).pop();
                      }
                    },
                    child: const Text('Add Report'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Team: ${report['team'] ?? 'Unknown'}'),
            Text('Position: ${report['position'] ?? 'Unknown'}'),
            Text('Age: ${report['age'] ?? 'Unknown'}'),
            Text('Rating: ${report['rating'] ?? '5.0'}/10'),
            const SizedBox(height: 16),
            const Text(
              'Strengths:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(report['strengths'] ?? ''),
            const SizedBox(height: 8),
            const Text(
              'Weaknesses:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(report['weaknesses'] ?? ''),
            const SizedBox(height: 8),
            const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(report['notes'] ?? ''),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
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
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ScoutingReportProvider>().deleteReport(report['id']);
              Navigator.of(context, rootNavigator: true).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CoachGuruTheme.errorRed,
              foregroundColor: CoachGuruTheme.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
