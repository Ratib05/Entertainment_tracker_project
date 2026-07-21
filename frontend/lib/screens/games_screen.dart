import 'package:flutter/material.dart';

import '../models/media_entry.dart';
import '../widgets/media_tile.dart';

/// GamesScreen displays all games in the tracker.
/// Similar to MoviesScreen but with a light/beige aesthetic.
/// Shows game library stats and average rating.
class GamesScreen extends StatelessWidget {
  const GamesScreen({
    super.key,
    /// List of game entries to display
    required this.entries,
    /// Callback when FAB is tapped (show add sheet)
    required this.onAdd,
    /// Callback when tile is tapped (show edit sheet)
    required this.onEdit,
    /// Callback when tile is swiped to delete
    required this.onDelete,
  });

  final List<MediaEntry> entries;
  final VoidCallback onAdd;
  final ValueChanged<MediaEntry> onEdit;
  final ValueChanged<String> onDelete;

  /// Calculate the average rating across all rated games.
  /// Returns null if no games have ratings.
  double? get _averageRating {
    // Filter to only games that have a rating
    final rated = entries.where((e) => e.rating != null).toList();
    if (rated.isEmpty) return null;
    // Sum all ratings and divide by count
    return rated.map((e) => e.rating!).reduce((a, b) => a + b) / rated.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Game mode: Pumpkin Spice accent color
    final accent = const Color(0xFFF96900);

    return Scaffold(
      // Game mode: Beige background
      backgroundColor: const Color(0xFFDCE2C8),

      // ========== APP BAR ==========
      appBar: AppBar(
        backgroundColor: const Color(0xFFDCE2C8),
        foregroundColor: Colors.black,
        surfaceTintColor: const Color(0xFFDCE2C8),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main title
            Text(
              'Games Tracker',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            // Subtitle
            Text(
              'Your games only',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
      
      // ========== BODY ==========
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ========== STATS CARD SECTION ==========
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: _GamesStatsCard(
              total: entries.length,
              averageRating: _averageRating,
              accentColor: accent,
            ),
          ),
          
          // ========== GAMES LIST OR EMPTY STATE ==========
          Expanded(
            child: entries.isEmpty
                // Show empty state if no games logged
                ? const _GamesEmptyState()
                // Show list of game entries
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return MediaTile(
                        entry: entry,
                        onTap: () => onEdit(entry),
                        onDelete: () => onDelete(entry.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      
      // ========== FAB ==========
      // Green FAB to match games theme
      floatingActionButton: FloatingActionButton(
        onPressed: onAdd,
        backgroundColor: accent,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// _GamesStatsCard displays summary statistics about the user's game library.
/// Shows: total game count and average rating across all games.
class _GamesStatsCard extends StatelessWidget {
  const _GamesStatsCard({
    required this.total,
    required this.averageRating,
    required this.accentColor,
  });

  final int total;
  final double? averageRating;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      // Game mode: Pearl Aqua card background
      color: const Color(0xFFA8DCD1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== HEADER ==========
            Row(
              children: [
                // Header icon (games/controller icon)
                Icon(Icons.sports_esports_outlined, color: accentColor),
                const SizedBox(width: 8),
                // Header text
                Text(
                  'Games Library',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // ========== STATS ROW ==========
            // Display 2 stat items in a row
            Row(
              children: [
                // Total games count
                _StatItem(label: 'Games', value: '$total'),
                // Average rating with optional star icon
                _StatItem(
                  label: 'Avg Rating',
                  value: averageRating == null
                      ? '—' // Dash if no ratings yet
                      : averageRating!.toStringAsFixed(1), // 1 decimal place
                  icon: averageRating != null ? Icons.star_rounded : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// _StatItem displays a single statistic (label + value).
/// Similar to MoviesScreen version but with light theme colors.
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          // ========== VALUE ROW ==========
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Optional icon (e.g., star icon for ratings)
              if (icon != null) ...[
                Icon(icon, size: 16, color: Colors.amber),
                const SizedBox(width: 2),
              ],
              // The actual value (e.g., "12" or "3.8")
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          
          // ========== LABEL ==========
          // Description of what the value represents
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
  }
}

/// _GamesEmptyState displays when there are no games in the library.
/// Provides helpful message and visual cue to add first game.
class _GamesEmptyState extends StatelessWidget {
  const _GamesEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ========== ICON CIRCLE ==========
            // Large circular icon with semi-transparent green background
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                // Game mode: Pumpkin Spice with low opacity
                color: const Color(0xFFF96900).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sports_esports_outlined,
                size: 40,
                color: Color(0xFFF96900), // Pumpkin Spice
              ),
            ),
            
            const SizedBox(height: 24),
            
            // ========== MAIN MESSAGE ==========
            Text(
              'No games logged',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // ========== HELP TEXT ==========
            Text(
              'Add a game to your library.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
