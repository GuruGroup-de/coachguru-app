import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'player_provider.dart';
import 'player_model.dart';
import '../theme/theme.dart';

/// Add Player Screen
/// Beautiful form for adding a new player with image picker and validation
class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({super.key});

  @override
  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthYearController = TextEditingController();

  String? _selectedPosition;
  String? _selectedFoot;
  File? _imageFile;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _positions = ['GK', 'DEF', 'MID', 'FW'];

  final List<String> _feet = ['Right', 'Left', 'Both'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthYearController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: CoachGuruTheme.errorRed,
          ),
        );
      }
    }
  }

  void _savePlayer() {
    if (_formKey.currentState!.validate()) {
      if (_selectedPosition == null || _selectedFoot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select position and strong foot'),
            backgroundColor: CoachGuruTheme.errorRed,
          ),
        );
        return;
      }

      final id = const Uuid().v4();
      final newPlayer = PlayerModel(
        id: id,
        name: _nameController.text.trim(),
        birthYear: int.parse(_birthYearController.text.trim()),
        position: _selectedPosition!,
        strongFoot: _selectedFoot!,
        photoPath: _imageFile?.path,
        goals: 0,
        assists: 0,
      );

      context.read<PlayerProvider>().addPlayer(newPlayer);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Player added successfully!'),
            backgroundColor: CoachGuruTheme.accentGreen,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Player'),
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar Picker Section
                  _buildAvatarSection(),
                  const SizedBox(height: 24),

                  // Input Form Section
                  _buildFormSection(),
                  const SizedBox(height: 24),

                  // Save Button
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: CoachGuruTheme.mainBlue.withAlpha((0.18 * 255).round()),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Circle Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.1 * 255).round()),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 80,
                backgroundColor: CoachGuruTheme.lightBlue,
                child: _imageFile != null
                    ? ClipOval(
                        child: Image.file(
                          _imageFile!,
                          width: 160,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 80,
                        color: CoachGuruTheme.mainBlue,
                      ),
              ),
            ),
            const SizedBox(height: 16),
            // Choose Photo Button
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose Photo'),
              style: TextButton.styleFrom(
                foregroundColor: CoachGuruTheme.mainBlue,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: CoachGuruTheme.mainBlue.withAlpha((0.18 * 255).round()),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Player Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CoachGuruTheme.textDark,
              ),
            ),
            const SizedBox(height: 20),

            // Full Name Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: const TextStyle(fontSize: 14),
                contentPadding: const EdgeInsets.all(14),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter player name';
                }
                if (value.trim().length < 3) {
                  return 'Name must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Birth Year Field
            TextFormField(
              controller: _birthYearController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Birth Year',
                prefixIcon: const Icon(Icons.cake),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: const TextStyle(fontSize: 14),
                contentPadding: const EdgeInsets.all(14),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter birth year';
                }
                if (value.trim().length != 4) {
                  return 'Birth year must be 4 digits';
                }
                final year = int.tryParse(value.trim());
                if (year == null) {
                  return 'Please enter a valid year';
                }
                if (year < 2007 || year > 2020) {
                  return 'Birth year must be between 2007 and 2020';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Position Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedPosition,
              decoration: InputDecoration(
                labelText: 'Position',
                prefixIcon: const Icon(Icons.sports_soccer),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: const TextStyle(fontSize: 14),
                contentPadding: const EdgeInsets.all(14),
              ),
              items: _positions.map((position) {
                return DropdownMenuItem<String>(
                  value: position,
                  child: Text(position),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPosition = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a position';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Strong Foot Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedFoot,
              decoration: InputDecoration(
                labelText: 'Strong Foot',
                prefixIcon: const Icon(Icons.directions_run),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: const TextStyle(fontSize: 14),
                contentPadding: const EdgeInsets.all(14),
              ),
              items: _feet.map((foot) {
                return DropdownMenuItem<String>(value: foot, child: Text(foot));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFoot = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select strong foot';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _savePlayer,
      icon: const Icon(Icons.check, size: 24),
      label: const Text(
        'Save Player',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: CoachGuruTheme.mainBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 4,
        shadowColor: CoachGuruTheme.mainBlue.withAlpha((0.3 * 255).round()),
      ),
    );
  }
}
