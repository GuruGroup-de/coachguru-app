import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../theme/theme.dart';
import '../../models/scouting_templates.dart';
import '../../utils/navigation_helper.dart';

/// Add Scouting Report Screen
/// Full screen form for adding a new scouting report
class AddScoutingReportScreen extends StatefulWidget {
  const AddScoutingReportScreen({super.key});

  @override
  State<AddScoutingReportScreen> createState() =>
      _AddScoutingReportScreenState();
}

class _AddScoutingReportScreenState extends State<AddScoutingReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _teamController = TextEditingController();
  final _positionController = TextEditingController();
  final _shirtNumberController = TextEditingController();
  final _ageController = TextEditingController();
  final _notesController = TextEditingController();
  ScoutingTemplate? selectedTemplate;

  @override
  void dispose() {
    _nameController.dispose();
    _teamController.dispose();
    _positionController.dispose();
    _shirtNumberController.dispose();
    _ageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void saveReport() {
    if (_formKey.currentState!.validate()) {
      if (_nameController.text.trim().isNotEmpty) {
        final newReport = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'playerName': _nameController.text.trim(),
          'team': _teamController.text.trim(),
          'position': _positionController.text.trim(),
          'shirtNumber': int.tryParse(_shirtNumberController.text) ?? 0,
          'age': int.tryParse(_ageController.text) ?? 0,
          'rating': 5.0,
          'strengths': '',
          'weaknesses': '',
          'notes': _notesController.text.trim(),
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        };

        context.read<ScoutingReportProvider>().addReport(newReport);

        if (mounted) {
          NavHelper.safePop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Scouting report added successfully!'),
              backgroundColor: CoachGuruTheme.accentGreen,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a player name'),
            backgroundColor: CoachGuruTheme.errorRed,
            duration: Duration(seconds: 2),
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
            backgroundColor: Colors.white,
            elevation: 1,
            title: const Text(
              'Add Report',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => NavHelper.safePop(context),
            ),
            actions: [
              TextButton(
                onPressed: saveReport,
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Player Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Player name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _teamController,
                    decoration: const InputDecoration(
                      labelText: 'Team',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _positionController,
                    decoration: const InputDecoration(
                      labelText: 'Position',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _shirtNumberController,
                    decoration: const InputDecoration(
                      labelText: 'T-Shirt Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  // Template Dropdown
                  DropdownButtonFormField<ScoutingTemplate>(
                    decoration: InputDecoration(
                      labelText: 'Select Template',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    value: selectedTemplate,
                    items: scoutingTemplates.map((template) {
                      return DropdownMenuItem<ScoutingTemplate>(
                        value: template,
                        child: Text(template.title),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTemplate = value;
                        if (value != null) {
                          _notesController.text = value.description;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Notes Field
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: 8,
                  ),
                  const SizedBox(height: 24),
                  // Action Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => NavHelper.safePop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: CoachGuruTheme.errorRed),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: saveReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CoachGuruTheme.mainBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Save Report',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
