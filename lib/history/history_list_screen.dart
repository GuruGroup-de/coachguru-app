import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'history_model.dart';
import 'history_storage.dart';
import 'history_add_edit_screen.dart';
import '../theme/theme.dart';

/// Simple Match History List Screen
class HistoryListScreen extends StatefulWidget {
  const HistoryListScreen({super.key});

  @override
  State<HistoryListScreen> createState() => _HistoryListScreenState();
}

class _HistoryListScreenState extends State<HistoryListScreen> {
  List<MatchHistory> _matches = [];
  bool _isLoading = true;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _loadHistory() async {
    if (!mounted || _isDisposed) return;

    try {
      final history = await HistoryStorage.loadHistory();
      if (!mounted || _isDisposed) return;
      setState(() {
        _matches = history;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || _isDisposed) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteMatch(MatchHistory match) async {
    if (!mounted || _isDisposed) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Match'),
        content: Text('Delete match vs ${match.opponent}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted && !_isDisposed) {
      _matches.removeWhere((m) => m.id == match.id);
      await HistoryStorage.saveHistory(_matches);
      if (mounted && !_isDisposed) {
        setState(() {});
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
          title: const Text('Match History'),
          backgroundColor: CoachGuruTheme.mainBlue,
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: CoachGuruTheme.mainBlue,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _matches.isEmpty
            ? _buildEmptyState()
            : _buildMatchesList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (!mounted || _isDisposed) return;
            final result = await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HistoryAddEditScreen()),
            );
            if (result == true && mounted && !_isDisposed) {
              _loadHistory();
            }
          },
          backgroundColor: CoachGuruTheme.mainBlue,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
                fontWeight: FontWeight.bold,
                color: CoachGuruTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first match',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: CoachGuruTheme.textLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _matches.length,
      itemBuilder: (context, index) {
        if (_isDisposed || !context.mounted) {
          return const SizedBox.shrink();
        }

        final match = _matches[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              match.opponent,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CoachGuruTheme.textDark,
              ),
            ),
            subtitle: Text(
              DateFormat('MMM dd, yyyy').format(match.date),
              style: TextStyle(fontSize: 14, color: CoachGuruTheme.textLight),
            ),
            trailing: Text(
              match.score,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CoachGuruTheme.mainBlue,
              ),
            ),
            onTap: () async {
              if (!context.mounted || _isDisposed) return;
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => HistoryAddEditScreen(match: match),
                ),
              );
              if (result == true && mounted && !_isDisposed) {
                _loadHistory();
              }
            },
            onLongPress: () {
              if (!context.mounted || _isDisposed) return;
              _deleteMatch(match);
            },
          ),
        );
      },
    );
  }
}
