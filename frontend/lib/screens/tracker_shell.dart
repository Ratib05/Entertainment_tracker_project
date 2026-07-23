import 'package:flutter/material.dart';

import '../data/memory_library_repository.dart';
import '../models/media_entry.dart';
import '../models/tracker_mode.dart';
import '../widgets/add_media_sheet.dart';
import 'discover_screen.dart';
import 'games_screen.dart';
import 'movies_screen.dart';
import 'settings_screen.dart';

/// TrackerShell is the main container that manages the app's state and navigation.
/// Bottom nav tabs: Movies, Games, Discover, Settings. Movies/Games keep their
/// existing screens and logic unchanged; Discover and Settings are now tabs
/// instead of a FAB-menu destination.
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

  /// Index of the currently selected bottom nav tab.
  int _selectedIndex = 0;

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
  Future<void> _showAddSheet(TrackerMode mode) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      // Allow scrolling if keyboard pops up
      isScrollControlled: true,
      // Show drag handle at top of sheet
      showDragHandle: true,
      backgroundColor: const Color(0xFF1A1A22),
      builder: (_) => AddMediaSheet(mode: mode),
    );

    // Exit if sheet was dismissed or not mounted anymore
    if (result == null || !mounted) return;

    // Insert the new entry
    _insertEntry(result);
  }

  /// Opens the edit sheet in modal bottom sheet for an existing entry.
  /// Pre-populates the form with existing data.
  /// Updates the entry if data is returned.
  Future<void> _showEditSheet(TrackerMode mode, MediaEntry entry) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFF1A1A22),
      builder: (_) => AddMediaSheet(mode: mode, entry: entry),
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
          seasonEpisodeCount: result['seasonEpisodeCount'] as int?,
          lastWatchedMinutes: result['lastWatchedMinutes'] as int?,
          clearRating: result['rating'] == null,
          clearSeason: result['season'] == null,
          clearWatchedDate: result['watchedDate'] == null,
          clearPosterUrl: result['posterUrl'] == null,
          clearYear: result['year'] == null,
          clearTmdbId: result['tmdbId'] == null,
          clearLastWatchedMinutes: result['lastWatchedMinutes'] == null,
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
          seasonEpisodeCount: result['seasonEpisodeCount'] as int?,
          lastWatchedMinutes: result['lastWatchedMinutes'] as int?,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          MoviesScreen(
            entries: _moviesEntries,
            onAdd: () => _showAddSheet(TrackerMode.movies),
            onEdit: (entry) => _showEditSheet(TrackerMode.movies, entry),
            onDelete: _deleteEntry,
          ),
          GamesScreen(
            entries: _gamesEntries,
            onAdd: () => _showAddSheet(TrackerMode.games),
            onEdit: (entry) => _showEditSheet(TrackerMode.games, entry),
            onDelete: _deleteEntry,
          ),
          DiscoverScreen(
            libraryEntries: _repository.getAll(),
            onAdd: _insertEntry,
          ),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0F0F12),
        indicatorColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.local_movies_outlined),
            selectedIcon: Icon(Icons.local_movies),
            label: 'Movies',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon: Icon(Icons.sports_esports),
            label: 'Games',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
