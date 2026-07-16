import 'package:flutter/material.dart';

import '../models/media_entry.dart';
import '../widgets/media_tile.dart';

class MoviesScreen extends StatelessWidget {
  const MoviesScreen({
    super.key,
    required this.entries,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<MediaEntry> entries;
  final VoidCallback onAdd;
  final ValueChanged<MediaEntry> onEdit;
  final ValueChanged<String> onDelete;

  int get _filmCount =>
      entries.where((e) => e.type == MediaType.film).length;

  int get _showCount =>
      entries.where((e) => e.type == MediaType.show).length;

  String get _approxScreenTime =>
      formatScreenTime(approxMoviesScreenMinutes(entries));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Get the primary color from the theme's color scheme
    final accent = theme.colorScheme.primary;

    return Scaffold(
      // Dark background color
      backgroundColor: Colors.black,
      
      // ========== APP BAR ==========
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main title
            Text(
              'Movies and Shows Tracker',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            // Subtitle
            Text(
              'Your films & shows',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
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
            child: _MoviesStatsCard(
              total: entries.length,
              films: _filmCount,
              shows: _showCount,
              screenTime: _approxScreenTime,
              accentColor: accent,
            ),
          ),
          
          // ========== MEDIA LIST OR EMPTY STATE ==========
          Expanded(
            child: entries.isEmpty
                // Show empty state if no entries
                ? _MoviesEmptyState(onAdd: onAdd)
                // Show list of entries
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
      floatingActionButton: FloatingActionButton(
        onPressed: onAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MoviesStatsCard extends StatelessWidget {
  const _MoviesStatsCard({
    required this.total,
    required this.films,
    required this.shows,
    required this.screenTime,
    required this.accentColor,
  });

  final int total;
  final int films;
  final int shows;
  final String screenTime;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      // Dark card background
      color: const Color(0xFF11131A),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== HEADER ==========
            Row(
              children: [
                // Header icon (movies icon)
                Icon(Icons.local_movies_outlined, color: accentColor),
                const SizedBox(width: 8),
                // Header text
                Text(
                  'Your Library',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                _StatItem(label: 'Total', value: '$total'),
                _StatItem(label: 'Films', value: '$films'),
                _StatItem(label: 'Shows', value: '$shows'),
                _StatItem(
                  label: 'Screen time',
                  value: screenTime,
                  icon: screenTime == '—' ? null : Icons.schedule_rounded,
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
/// Multiple _StatItems are placed in a row to create a stats grid.
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
                Icon(icon, size: 16, color: Colors.grey.shade400),
                const SizedBox(width: 2),
              ],
              // The actual value (e.g., "25" or "4.2")
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

/// _MoviesEmptyState displays when there are no entries in the library.
/// Provides helpful message and button to add first entry.
class _MoviesEmptyState extends StatelessWidget {
  const _MoviesEmptyState({required this.onAdd});

  final VoidCallback onAdd;

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
            // Large circular icon with semi-transparent background
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                // Use primary theme color with low opacity
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.movie_creation_outlined,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // ========== MAIN MESSAGE ==========
            Text(
              'Nothing logged yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // ========== HELP TEXT ==========
            Text(
              'Start tracking the films and shows you enjoy.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // ========== CTA BUTTON ==========
            // Button to add the first entry
            FilledButton.tonal(
              onPressed: onAdd,
              child: const Text('Log your first title'),
            ),
          ],
        ),
      ),
    );
  }
}
