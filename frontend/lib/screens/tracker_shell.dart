import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/memory_library_repository.dart';
import '../models/media_entry.dart';
import '../models/tracker_mode.dart';
import '../providers/theme_provider.dart';
import '../widgets/add_media_sheet.dart';
import 'games_screen.dart';
import 'movies_screen.dart';

/// TrackerShell is the main container that manages the app's state and navigation.
/// It handles switching between Movies and Games screens, showing/hiding the add/edit sheets,
/// and managing CRUD operations on media entries.
class TrackerShell extends StatefulWidget {
  const TrackerShell({super.key});

  @override
  State<TrackerShell> createState() => _TrackerShellState();
}

class _TrackerShellState extends State<TrackerShell> {
  // ========== DATA MANAGEMENT ==========
  /// Repository for storing and retrieving media entries.
  /// Uses in-memory storage (data doesn't persist between app restarts).
  final MemoryLibraryRepository _repository = MemoryLibraryRepository();
  
  /// Current mode: either showing movies or games.
  /// Determines which screen is displayed.
  TrackerMode _mode = TrackerMode.movies;

  // ========== FILTERED ENTRY LISTS ==========
  /// Get all movies and shows (excludes games).
  /// Returns a new list each time it's accessed.
  List<MediaEntry> get _moviesEntries => _repository
      .getAll()
      .where((e) => e.type == MediaType.film || e.type == MediaType.show)
      .toList();

  /// Get all games (excludes movies and shows).
  /// Returns a new list each time it's accessed.
  List<MediaEntry> get _gamesEntries =>
      _repository.getAll().where((e) => e.type == MediaType.game).toList();

  // ========== SHEET MANAGEMENT ==========
  /// Opens the add sheet in modal bottom sheet.
  /// Returns the result from AddMediaSheet (map of form data).
  /// Creates a new entry if data is returned.
  Future<void> _showAddSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      // Allow scrolling if keyboard pops up
      isScrollControlled: true,
      // Show drag handle at top of sheet
      showDragHandle: true,
      backgroundColor: const Color(0xFF1A1A22),
      builder: (_) => AddMediaSheet(mode: _mode),
    );

    // Exit if sheet was dismissed or not mounted anymore
    if (result == null || !mounted) return;
    
    // Insert the new entry
    _insertEntry(result);
  }

  /// Opens the edit sheet in modal bottom sheet for an existing entry.
  /// Pre-populates the form with existing data.
  /// Updates the entry if data is returned.
  Future<void> _showEditSheet(MediaEntry entry) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFF1A1A22),
      builder: (_) => AddMediaSheet(mode: _mode, entry: entry),
    );

    // Exit if sheet was dismissed or not mounted anymore
    if (result == null || !mounted) return;

    // Update the existing entry with new data
    setState(() {
      _repository.update(
        entry.copyWith(
          title: result['title'] as String,
          note: result['note'] as String,
          type: result['type'] as MediaType,
          status: result['status'] as WatchStatus,
          rating: result['rating'] as int?,
          season: result['season'] as int?,
          watchedDate: result['watchedDate'] as DateTime?,
          // These flags tell copyWith to explicitly set these fields to null
          clearRating: result['rating'] == null,
          clearSeason: result['season'] == null,
          clearWatchedDate: result['watchedDate'] == null,
        ),
      );
    });
  }

  // ========== CRUD OPERATIONS ==========
  /// Creates a new entry from form data and adds it to the repository.
  /// Called after user submits the add sheet.
  void _insertEntry(Map<String, dynamic> result) {
    setState(() {
      _repository.add(
        MediaEntry(
          // Generate unique ID from repository
          id: _repository.nextId(),
          title: result['title'] as String,
          note: result['note'] as String,
          type: result['type'] as MediaType,
          status: result['status'] as WatchStatus,
          rating: result['rating'] as int?,
          season: result['season'] as int?,
          loggedAt: DateTime.now(),
          watchedDate: result['watchedDate'] as DateTime?,
        ),
      );
    });
  }

  /// Deletes an entry from the repository and shows confirmation snackbar.
  /// Called when user swipes to delete a tile.
  void _deleteEntry(String id) {
    setState(() => _repository.delete(id));
    
    // Show confirmation that entry was removed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed from log'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2A2A35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ========== NAVIGATION ==========
  /// Toggles between movies and games mode.
  /// Called when user taps the mode toggle button.
  void _toggleMode() {
    setState(() {
      _mode = _mode == TrackerMode.movies
          ? TrackerMode.games
          : TrackerMode.movies;
    });
    context.read<ThemeProvider>().setMode(_mode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGameMode = _mode == TrackerMode.games;

    return Scaffold(
      // ========== BODY: CONDITIONAL SCREEN DISPLAY ==========
      // Show different screen based on current mode
      body: isGameMode
          ? GamesScreen(
              entries: _gamesEntries,
              onAdd: _showAddSheet,
              onEdit: _showEditSheet,
              onDelete: _deleteEntry,
            )
          : MoviesScreen(
              entries: _moviesEntries,
              onAdd: _showAddSheet,
              onEdit: _showEditSheet,
              onDelete: _deleteEntry,
            ),
      
      // ========== BOTTOM APP BAR ==========
      // Provides mode toggle button and mode description
      bottomNavigationBar: BottomAppBar(
        // Different background color based on mode
        color: isGameMode ? const Color(0xFFD9D9D9) : const Color(0xFF353535),
        elevation: 0,
        height: 88,
        padding: EdgeInsets.zero,
        // Allow bottom button to extend into FAB space
        clipBehavior: Clip.none,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ========== MODE TOGGLE BUTTON ==========
              // Tap to switch between movies and games
              GestureDetector(
                onTap: _toggleMode,
                child: Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    // Different colors for each mode
                    color: isGameMode
                        ? const Color(0xFF284B63) // Yale Blue for switch to movies
                        : const Color(0xFFBCE7FD), // Icy Blue for switch to games
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    // Icon indicates the OTHER mode (what you'll switch to)
                    isGameMode ? Icons.local_movies : Icons.sports_esports,
                    color: isGameMode ? const Color(0xFFD9D9D9) : const Color(0xFF353535),
                    size: 26,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // ========== MODE DESCRIPTION TEXT ==========
              // Explain what the button does
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isGameMode
                        ? 'Switch to movie tracker'
                        : 'Tap to show games in your tracker.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          isGameMode ? const Color(0xFF9EB7B8) : const Color(0xFF353535),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
