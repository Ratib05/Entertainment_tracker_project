import 'package:flutter/material.dart';

import '../data/entertainment_api_service.dart';
import '../models/media_entry.dart';
import '../models/media_search_result.dart';

/// Shows genre-matched recommendations pulled from TMDB. Genres are inferred
/// from [libraryEntries]; falls back to TMDB's "popular" list when the
/// library is empty or has no genre data yet. Excludes R18+/X18+/RC-tier
/// content (search results are never filtered this way, only Discover).
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({
    super.key,
    required this.libraryEntries,
    required this.onAdd,
  });

  final List<MediaEntry> libraryEntries;
  final void Function(Map<String, dynamic> result) onAdd;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final EntertainmentApiService _entertainmentApi = EntertainmentApiService();
  final ScrollController _scrollController = ScrollController();

  MediaType _type = MediaType.film;
  DiscoverSort _sort = DiscoverSort.popularity;
  List<String> _availableGenres = [];
  Set<String> _selectedGenres = {};
  bool _loadingGenres = true;

  List<MediaSearchResult> _results = [];
  int _page = 1;
  bool _hasMore = true;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int? _addingTmdbId;

  List<String> get _inferredTopGenres {
    final counts = <String, int>{};
    for (final entry in widget.libraryEntries) {
      for (final genre in entry.genres) {
        counts[genre] = (counts[genre] ?? 0) + 1;
      }
    }
    final sorted = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    return sorted.take(3).toList();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadGenreOptions();
  }

  Future<void> _loadGenreOptions() async {
    setState(() => _loadingGenres = true);
    try {
      final genres = await _entertainmentApi.genres(_type);
      if (!mounted) return;
      final inferred = _inferredTopGenres.where(genres.contains).toSet();
      setState(() {
        _availableGenres = genres;
        _selectedGenres = inferred;
        _loadingGenres = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _availableGenres = [];
        _loadingGenres = false;
      });
    }
    _load();
  }

  void _toggleGenre(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }
    });
    _load();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore || _loading) return;
    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _page = 1;
      _hasMore = true;
    });

    try {
      final results = await _entertainmentApi.discover(
        type: _type,
        genres: _selectedGenres.toList(),
        page: _page,
        sort: _sort,
      );
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
        _hasMore = results.isNotEmpty;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _results = [];
        _loading = false;
        _error = 'Couldn\'t load recommendations. Check your connection and try again.';
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);

    final nextPage = _page + 1;
    try {
      final results = await _entertainmentApi.discover(
        type: _type,
        genres: _selectedGenres.toList(),
        page: nextPage,
        sort: _sort,
      );
      if (!mounted) return;
      setState(() {
        _page = nextPage;
        _results = [..._results, ...results];
        _hasMore = results.isNotEmpty;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      // Best-effort: stay on the current results and let the user retry by scrolling again.
      setState(() => _loadingMore = false);
    }
  }

  Future<void> _addToWatchlist(MediaSearchResult result) async {
    setState(() => _addingTmdbId = result.tmdbId);

    final type = result.type == MediaSearchType.show
        ? MediaType.show
        : MediaType.film;

    try {
      final imported = await _entertainmentApi.import(result.tmdbId, type);
      if (!mounted) return;

      widget.onAdd({
        'title': result.title,
        'note': '',
        'type': type,
        'status': WatchStatus.watchlist,
        'rating': null,
        'season': null,
        'watchedDate': null,
        'posterUrl': result.posterUrl,
        'year': result.year,
        'tmdbId': result.tmdbId,
        'genres': (imported['genres'] as List<dynamic>?)?.cast<String>(),
        'runtimeMinutes': imported['runtime_minutes'] as int?,
        'episodeRuntimeMinutes': imported['episode_runtime_minutes'] as int?,
        'numberOfEpisodes': imported['number_of_episodes'] as int?,
        'numberOfSeasons': imported['number_of_seasons'] as int?,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added "${result.title}" to your watchlist'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2A2A35),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Couldn\'t add "${result.title}". Try again.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2A2A35),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _addingTmdbId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.black,
        title: const Text('Discover'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: SegmentedButton<MediaType>(
              segments: const [
                ButtonSegment(
                  value: MediaType.film,
                  icon: Icon(Icons.movie_outlined),
                  label: Text('Films'),
                ),
                ButtonSegment(
                  value: MediaType.show,
                  icon: Icon(Icons.tv_outlined),
                  label: Text('Shows'),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (selection) {
                setState(() => _type = selection.first);
                _loadGenreOptions();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(
              children: [
                Text(
                  'Sort',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SegmentedButton<DiscoverSort>(
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                    segments: const [
                      ButtonSegment(
                        value: DiscoverSort.popularity,
                        label: Text('Popular'),
                      ),
                      ButtonSegment(
                        value: DiscoverSort.rating,
                        label: Text('Top Rated'),
                      ),
                      ButtonSegment(
                        value: DiscoverSort.newest,
                        label: Text('Newest'),
                      ),
                    ],
                    selected: {_sort},
                    onSelectionChanged: (selection) {
                      setState(() => _sort = selection.first);
                      _load();
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_loadingGenres)
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_availableGenres.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _availableGenres.map((genre) {
                  final selected = _selectedGenres.contains(genre);
                  return FilterChip(
                    label: Text(genre),
                    selected: selected,
                    onSelected: (_) => _toggleGenre(genre),
                    backgroundColor: const Color(0xFF1A1A22),
                    selectedColor: theme.colorScheme.primary.withValues(alpha: 0.25),
                    labelStyle: TextStyle(
                      color: selected ? theme.colorScheme.primary : Colors.grey.shade400,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: selected ? theme.colorScheme.primary : Colors.grey.shade800,
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 4),
          Expanded(child: _buildBody(theme)),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Text(
          'No recommendations found.',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
        ),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.52,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _DiscoverTile(
                result: _results[index],
                isAdding: _addingTmdbId == _results[index].tmdbId,
                onAdd: () => _addToWatchlist(_results[index]),
              ),
              childCount: _results.length,
            ),
          ),
        ),
        if (_loadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }
}

class _DiscoverTile extends StatelessWidget {
  const _DiscoverTile({
    required this.result,
    required this.isAdding,
    required this.onAdd,
  });

  final MediaSearchResult result;
  final bool isAdding;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox.expand(
                  child: result.posterUrl == null
                      ? ColoredBox(
                          color: Colors.grey.shade900,
                          child: Icon(
                            result.type == MediaSearchType.show
                                ? Icons.tv_outlined
                                : Icons.movie_outlined,
                            color: Colors.grey.shade600,
                          ),
                        )
                      : Image.network(
                          result.posterUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              ColoredBox(
                            color: Colors.grey.shade900,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: Material(
                  color: Colors.black87,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: isAdding ? null : onAdd,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: isAdding
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          result.displayTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
