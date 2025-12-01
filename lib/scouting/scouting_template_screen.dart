import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/scouting_provider.dart';
import '../theme/theme.dart';
import '../utils/navigation_helper.dart';

/// Scouting Template Screen
/// Form for creating a new scouting report for a player
class ScoutingTemplateScreen extends StatefulWidget {
  final String playerId;

  const ScoutingTemplateScreen({super.key, required this.playerId});

  @override
  State<ScoutingTemplateScreen> createState() => _ScoutingTemplateScreenState();
}

class _ScoutingTemplateScreenState extends State<ScoutingTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _strengthsController = TextEditingController();
  final _weaknessesController = TextEditingController();
  final _summaryController = TextEditingController();
  String _selectedPotential = 'Medium';

  final List<String> _potentialOptions = ['High', 'Medium', 'Low'];

  @override
  void dispose() {
    _strengthsController.dispose();
    _weaknessesController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _saveReport() {
    if (_formKey.currentState!.validate()) {
      context.read<ScoutingProvider>().addScoutingNote(
        playerId: widget.playerId,
        strengths: _strengthsController.text.trim(),
        weaknesses: _weaknessesController.text.trim(),
        potential: _selectedPotential,
        summary: _summaryController.text.trim(),
      );

      if (mounted) {
        NavHelper.safePop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scouting report saved successfully!'),
            backgroundColor: CoachGuruTheme.accentGreen,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        NavHelper.safePop(context);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('New Scouting Report'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => NavHelper.safePop(context),
            ),
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: CoachGuruTheme.mainBlue,
              statusBarIconBrightness: Brightness.light,
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [CoachGuruTheme.lightBlue, CoachGuruTheme.softGrey],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Strengths Section
                    _buildSectionCard(
                      title: 'Strengths',
                      icon: Icons.trending_up,
                      child: TextFormField(
                        controller: _strengthsController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Describe the player\'s strengths...',
                          hintStyle: TextStyle(color: CoachGuruTheme.textLight),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please describe the player\'s strengths';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Weaknesses Section
                    _buildSectionCard(
                      title: 'Weaknesses',
                      icon: Icons.trending_down,
                      child: TextFormField(
                        controller: _weaknessesController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Describe areas for improvement...',
                          hintStyle: TextStyle(color: CoachGuruTheme.textLight),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please describe areas for improvement';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Potential Section
                    _buildSectionCard(
                      title: 'Potential',
                      icon: Icons.star,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedPotential,
                        decoration: InputDecoration(
                          hintText: 'Select potential level',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        items: _potentialOptions.map((option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPotential = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select potential level';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Summary Section
                    _buildSectionCard(
                      title: 'Summary',
                      icon: Icons.description,
                      child: TextFormField(
                        controller: _summaryController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: 'Overall assessment and recommendations...',
                          hintStyle: TextStyle(color: CoachGuruTheme.textLight),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please provide a summary';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton.icon(
                      onPressed: _saveReport,
                      icon: const Icon(Icons.save, size: 24),
                      label: const Text(
                        'Save Report',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CoachGuruTheme.mainBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                        shadowColor: CoachGuruTheme.mainBlue.withAlpha(
                          (0.3 * 255).round(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: CoachGuruTheme.mainBlue.withAlpha((0.18 * 255).round()),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: CoachGuruTheme.mainBlue, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CoachGuruTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
