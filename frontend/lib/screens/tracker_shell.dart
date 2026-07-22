import 'package:flutter/material.dart';

import '../data/memory_library_repository.dart';
import '../models/media_entry.dart';
import '../models/tracker_mode.dart';
import '../widgets/add_media_sheet.dart';
import 'discover_screen.dart';
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
  /// Handles the FAB tap. In movies mode, shows a small popup near the FAB
  /// with a choice between browsing Discover and adding a title directly;
  /// games mode has no Discover yet, so it opens the add sheet straight away.
  Future<void> _handleFabPressed() async {
    if (_mode == TrackerMode.games) {
      await _showAddSheet();
      return;
    }

    final overlayBox = Overlay.of(context).context.findRenderObject() as RenderBox;
    final size = overlayBox.size;
    final accent = Theme.of(context).colorScheme.primary;

    final choice = await showMenu<_FabChoice>(
      context: context,
      color: const Color(0xFF1A1A22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      position: RelativeRect.fromLTRB(
        size.width - 210,
        size.height - 260,
        16,
        100,
      ),
      items: [
        PopupMenuItem(
          value: _FabChoice.discover,
          child: Row(
            children: [
              Icon(Icons.explore_outlined, color: accent, size: 20),
              const SizedBox(width: 12),
              const Text('Discover', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        PopupMenuItem(
          value: _FabChoice.addTitle,
          child: Row(
            children: [
              Icon(Icons.add_circle_outline, color: accent, size: 20),
              const SizedBox(width: 12),
              const Text('Add a title', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );

    if (choice == null || !mounted) return;

    switch (choice) {
      case _FabChoice.discover:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DiscoverScreen(
              libraryEntries: _repository.getAll(),
              onAdd: _insertEntry,
            ),
          ),
        );
      case _FabChoice.addTitle:
        await _showAddSheet();
    }
  }

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

    if (result['action'] == 'delete') {
      _deleteEntry(entry.id);
      return;
    }

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
          posterUrl: result['posterUrl'] as String?,
          year: result['year'] as int?,
          tmdbId: result['tmdbId'] as int?,
          genres: result['genres'] as List<String>?,
          runtimeMinutes: result['runtimeMinutes'] as int?,
          episodeRuntimeMinutes: result['episodeRuntimeMinutes'] as int?,
          numberOfEpisodes: result['numberOfEpisodes'] as int?,
          numberOfSeasons: result['numberOfSeasons'] as int?,
          clearRating: result['rating'] == null,
          clearSeason: result['season'] == null,
          clearWatchedDate: result['watchedDate'] == null,
          clearPosterUrl: result['posterUrl'] == null,
          clearYear: result['year'] == null,
          clearTmdbId: result['tmdbId'] == null,
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
          id: _repository.nextId(),
          title: result['title'] as String,
          note: result['note'] as String,
          type: result['type'] as MediaType,
          status: result['status'] as WatchStatus,
          rating: result['rating'] as int?,
          season: result['season'] as int?,
          loggedAt: DateTime.now(),
          watchedDate: result['watchedDate'] as DateTime?,
          posterUrl: result['posterUrl'] as String?,
          year: result['year'] as int?,
          tmdbId: result['tmdbId'] as int?,
          genres: result['genres'] as List<String>? ?? const [],
          runtimeMinutes: result['runtimeMinutes'] as int?,
          episodeRuntimeMinutes: result['episodeRuntimeMinutes'] as int?,
          numberOfEpisodes: result['numberOfEpisodes'] as int?,
          numberOfSeasons: result['numberOfSeasons'] as int?,
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
              onAdd: _handleFabPressed,
              onEdit: _showEditSheet,
              onDelete: _deleteEntry,
            )
          : MoviesScreen(
              entries: _moviesEntries,
              onAdd: _handleFabPressed,
              onEdit: _showEditSheet,
              onDelete: _deleteEntry,
            ),
      
      // ========== BOTTOM APP BAR ==========
      // Provides mode toggle button and mode description
      bottomNavigationBar: BottomAppBar(
        // Different background color based on mode (light for games, dark for movies)
        color: isGameMode ? const Color(0xFFF4EEE5) : Colors.black,
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
                        ? Colors.blue.shade600 // Show "Switch to movies" button in blue
                        : Colors.green.shade600, // Show "Switch to games" button in green
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    // Icon indicates the OTHER mode (what you'll switch to)
                    isGameMode ? Icons.local_movies : Icons.sports_esports,
                    color: Colors.white,
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
                          isGameMode ? Colors.black87 : Colors.grey.shade500,
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

enum _FabChoice { discover, addTitle }
