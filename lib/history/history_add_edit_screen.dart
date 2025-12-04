import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'history_model.dart';
import 'history_storage.dart';
import '../theme/theme.dart';

/// Screen for adding or editing a match
class HistoryAddEditScreen extends StatefulWidget {
  final MatchHistory? match;

  const HistoryAddEditScreen({super.key, this.match});

  @override
  State<HistoryAddEditScreen> createState() => _HistoryAddEditScreenState();
}

class _HistoryAddEditScreenState extends State<HistoryAddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _opponentController = TextEditingController();
  final _goalsForController = TextEditingController();
  final _goalsAgainstController = TextEditingController();
  final _scorersController = TextEditingController();
  final _assistsController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    if (widget.match != null) {
      _opponentController.text = widget.match!.opponent;
      _goalsForController.text = widget.match!.goalsFor.toString();
      _goalsAgainstController.text = widget.match!.goalsAgainst.toString();
      _scorersController.text = widget.match!.scorers.join(', ');
      _assistsController.text = widget.match!.assists.join(', ');
      _selectedDate = widget.match!.date;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _opponentController.dispose();
    _goalsForController.dispose();
    _goalsAgainstController.dispose();
    _scorersController.dispose();
    _assistsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    if (!mounted || _isDisposed) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted && !_isDisposed) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveMatch() async {
    if (!_formKey.currentState!.validate() || !mounted || _isDisposed) return;

    try {
      final scorers = _scorersController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final assists = _assistsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final match = MatchHistory(
        id: widget.match?.id ?? const Uuid().v4(),
        opponent: _opponentController.text.trim(),
        date: _selectedDate,
        goalsFor: int.tryParse(_goalsForController.text) ?? 0,
        goalsAgainst: int.tryParse(_goalsAgainstController.text) ?? 0,
        scorers: scorers,
        assists: assists,
      );

      final history = await HistoryStorage.loadHistory();
      if (widget.match != null) {
        final index = history.indexWhere((m) => m.id == widget.match!.id);
        if (index != -1) {
          history[index] = match;
        }
      } else {
        history.add(match);
      }
      history.sort((a, b) => b.date.compareTo(a.date));

      await HistoryStorage.saveHistory(history);

      if (mounted && !_isDisposed) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving match: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && mounted) {
          _isDisposed = true;
        }
      },
      child: Scaffold(
        backgroundColor: CoachGuruTheme.softGrey,
        appBar: AppBar(
          title: Text(widget.match == null ? 'Add Match' : 'Edit Match'),
          backgroundColor: CoachGuruTheme.mainBlue,
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: CoachGuruTheme.mainBlue,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _opponentController,
                          decoration: InputDecoration(
                            labelText: 'Opponent',
                            prefixIcon: const Icon(Icons.group),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _selectDate,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Date',
                              prefixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _goalsForController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  labelText: 'Goals For',
                                  prefixIcon: const Icon(Icons.sports_soccer),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _goalsAgainstController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  labelText: 'Goals Against',
                                  prefixIcon: const Icon(Icons.sports_soccer),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _scorersController,
                          decoration: InputDecoration(
                            labelText: 'Scorers (comma separated)',
                            prefixIcon: const Icon(Icons.star),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: 'Player1, Player2',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _assistsController,
                          decoration: InputDecoration(
                            labelText: 'Assists (comma separated)',
                            prefixIcon: const Icon(Icons.assistant),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: 'Player1, Player2',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _saveMatch,
                  icon: const Icon(Icons.check, size: 24),
                  label: const Text(
                    'Save Match',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
