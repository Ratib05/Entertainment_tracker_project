import 'package:flutter/material.dart';

import '../models/media_entry.dart';
import '../widgets/add_media_sheet.dart';
import '../widgets/media_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<MediaEntry> _entries = [];
  MediaFilter _filter = MediaFilter.all;
  int _nextId = 1;

  List<MediaEntry> get _filteredEntries {
    switch (_filter) {
      case MediaFilter.all:
        return _entries;
      case MediaFilter.films:
        return _entries.where((e) => e.type == MediaType.film).toList();
      case MediaFilter.shows:
        return _entries.where((e) => e.type == MediaType.show).toList();
      case MediaFilter.watchlist:
        return _entries
            .where((e) => e.status == WatchStatus.watchlist)
            .toList();
      case MediaFilter.watched:
        return _entries.where((e) => e.status == WatchStatus.watched).toList();
    }
  }

  int get _filmCount =>
      _entries.where((e) => e.type == MediaType.film).length;

  int get _showCount =>
      _entries.where((e) => e.type == MediaType.show).length;

  double? get _averageRating {
    final rated = _entries.where((e) => e.rating != null).toList();
    if (rated.isEmpty) return null;
    return rated.map((e) => e.rating!).reduce((a, b) => a + b) / rated.length;
  }

  Future<void> _showAddSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFF1A1A22),
      builder: (_) => const AddMediaSheet(),
    );

    if (result == null || !mounted) return;
    _insertEntry(result);
  }

  Future<void> _showEditSheet(MediaEntry entry) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFF1A1A22),
      builder: (_) => AddMediaSheet(entry: entry),
    );

    if (result == null || !mounted) return;

    setState(() {
      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index == -1) return;
      _entries[index] = entry.copyWith(
        title: result['title'] as String,
        note: result['note'] as String,
        type: result['type'] as MediaType,
        status: result['status'] as WatchStatus,
        rating: result['rating'] as int?,
        season: result['season'] as int?,
        watchedDate: result['watchedDate'] as DateTime?,
        clearRating: result['rating'] == null,
        clearSeason: result['season'] == null,
        clearWatchedDate: result['watchedDate'] == null,
      );
    });
  }

  void _insertEntry(Map<String, dynamic> result) {
    setState(() {
      _entries.insert(
        0,
        MediaEntry(
          id: '${_nextId++}',
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

  void _deleteEntry(String id) {
    setState(() => _entries.removeWhere((e) => e.id == id));
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
    final theme = Theme.of(context);
    final filtered = _filteredEntries;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ReelLog',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Your films & shows',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: _StatsCard(
              total: _entries.length,
              films: _filmCount,
              shows: _showCount,
              averageRating: _averageRating,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SegmentedButton<MediaFilter>(
              segments: const [
                ButtonSegment(value: MediaFilter.all, label: Text('All')),
                ButtonSegment(value: MediaFilter.films, label: Text('Films')),
                ButtonSegment(value: MediaFilter.shows, label: Text('Shows')),
                ButtonSegment(
                  value: MediaFilter.watchlist,
                  label: Text('Watchlist'),
                ),
                ButtonSegment(
                  value: MediaFilter.watched,
                  label: Text('Watched'),
                ),
              ],
              selected: {_filter},
              onSelectionChanged: (selection) {
                setState(() => _filter = selection.first);
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(filter: _filter, onAdd: _showAddSheet)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final entry = filtered[index];
                      return MediaTile(
                        entry: entry,
                        onTap: () => _showEditSheet(entry),
                        onDelete: () => _deleteEntry(entry.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        icon: const Icon(Icons.add),
        label: const Text('Log Title'),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.total,
    required this.films,
    required this.shows,
    required this.averageRating,
  });

  final int total;
  final int films;
  final int shows;
  final double? averageRating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_movies_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
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
                  label: 'Avg Rating',
                  value: averageRating == null
                      ? '—'
                      : averageRating!.toStringAsFixed(1),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: Colors.amber),
                const SizedBox(width: 2),
              ],
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.filter,
    required this.onAdd,
  });

  final MediaFilter filter;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (icon, title, subtitle) = switch (filter) {
      MediaFilter.all => (
          Icons.movie_creation_outlined,
          'Nothing logged yet',
          'Start tracking the films and shows you watch.',
        ),
      MediaFilter.films => (
          Icons.movie_outlined,
          'No films logged',
          'Add a film to your library.',
        ),
      MediaFilter.shows => (
          Icons.tv_outlined,
          'No shows logged',
          'Add a TV show to your library.',
        ),
      MediaFilter.watchlist => (
          Icons.bookmark_outline,
          'Watchlist is empty',
          'Save titles you want to watch later.',
        ),
      MediaFilter.watched => (
          Icons.check_circle_outline,
          'Nothing watched yet',
          'Mark titles as watched to see them here.',
        ),
    };

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
            if (filter == MediaFilter.all) ...[
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: onAdd,
                child: const Text('Log your first title'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
