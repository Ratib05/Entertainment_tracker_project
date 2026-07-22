import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/entertainment_api_service.dart';
import '../models/media_entry.dart';
import '../models/media_search_result.dart';
import '../models/tracker_mode.dart';

class AddMediaSheet extends StatefulWidget {
  const AddMediaSheet({
    super.key,
    required this.mode,
    this.entry,
  });

  final TrackerMode mode;
  final MediaEntry? entry;

  @override
  State<AddMediaSheet> createState() => _AddMediaSheetState();
}

class _AddMediaSheetState extends State<AddMediaSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late final TextEditingController _seasonController;
  late MediaType _type;
  late WatchStatus _status;
  int? _rating;
  String? _posterUrl;
  int? _year;
  int? _tmdbId;

  final EntertainmentApiService _entertainmentApi = EntertainmentApiService();
  Timer? _debounce;
  List<MediaSearchResult> _results = [];
  bool _searching = false;
  String? _searchError;
  bool _pickedFromSearch = false;
  bool _saving = false;

  // Real per-season episode counts from TMDB, populated as soon as a show
  // is picked (or on init when editing an existing show entry).
  List<Map<String, dynamic>> _seasons = [];
  int? _selectedSeason;
  bool _loadingSeasons = false;
  Map<String, dynamic>? _cachedImport;

  bool get _isEditing => widget.entry != null;
  bool get _isGamesMode => widget.mode == TrackerMode.games;

  List<MediaType> get _allowedTypes => _isGamesMode
      ? const [MediaType.game]
      : const [MediaType.film, MediaType.show];

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _titleController = TextEditingController(text: entry?.title ?? '');
    _noteController = TextEditingController(text: entry?.note ?? '');
    _seasonController = TextEditingController(
      text: entry?.season?.toString() ?? '',
    );
    _type = entry?.type ?? (_isGamesMode ? MediaType.game : MediaType.film);
    if (!_allowedTypes.contains(_type)) {
      _type = _allowedTypes.first;
    }
    _status = entry?.status ?? WatchStatus.watchlist;
    _rating = entry?.rating;
    _posterUrl = entry?.posterUrl;
    _year = entry?.year;
    _tmdbId = entry?.tmdbId;
    _pickedFromSearch = entry?.tmdbId != null;

    if (_type == MediaType.show && _tmdbId != null) {
      _loadSeasons(_tmdbId!, preferredSeason: entry?.season);
    }
  }

  Future<void> _loadSeasons(int tmdbId, {int? preferredSeason}) async {
    setState(() {
      _loadingSeasons = true;
      _seasons = [];
      _selectedSeason = null;
    });

    try {
      final imported = await _entertainmentApi.import(tmdbId, MediaType.show);
      final seasons = ((imported['seasons'] as List<dynamic>?) ?? [])
          .cast<Map<String, dynamic>>();
      if (!mounted) return;

      final hasPreferred =
          preferredSeason != null && seasons.any((s) => s['season_number'] == preferredSeason);

      setState(() {
        _seasons = seasons;
        _selectedSeason = seasons.isEmpty
            ? null
            : (hasPreferred ? preferredSeason : seasons.first['season_number'] as int);
        _cachedImport = imported;
        _loadingSeasons = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _seasons = [];
        _selectedSeason = null;
        _loadingSeasons = false;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleController.dispose();
    _noteController.dispose();
    _seasonController.dispose();
    super.dispose();
  }

  void _onTitleChanged(String value) {
    if (_isGamesMode) return;

    setState(() {
      _pickedFromSearch = false;
      _posterUrl = null;
      _year = null;
      _tmdbId = null;
      _seasons = [];
      _selectedSeason = null;
      _cachedImport = null;
    });

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _runSearch(value);
    });
  }

  Future<void> _runSearch(String query) async {
    if (_isGamesMode) return;

    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _searching = false;
        _searchError = null;
      });
      return;
    }

    setState(() {
      _searching = true;
      _searchError = null;
    });

    try {
      final results = await _entertainmentApi.search(query, _type);
      if (!mounted || _titleController.text.trim() != query.trim()) return;
      setState(() {
        _results = results;
        _searching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _results = [];
        _searching = false;
        _searchError = 'Search failed. Check your connection and try again.';
      });
    }
  }

  void _selectResult(MediaSearchResult result) {
    setState(() {
      _titleController.text = result.title;
      _titleController.selection = TextSelection.collapsed(
        offset: result.title.length,
      );
      _posterUrl = result.posterUrl;
      _year = result.year;
      _tmdbId = result.tmdbId;
      _type = result.type == MediaSearchType.show
          ? MediaType.show
          : MediaType.film;
      _pickedFromSearch = true;
      _results = [];
      _searchError = null;
      _cachedImport = null;
    });

    if (result.type == MediaSearchType.show) {
      _loadSeasons(result.tmdbId);
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final seasonText = _seasonController.text.trim();
    final season = seasonText.isEmpty ? null : int.tryParse(seasonText);

    // Sync to the shared backend catalog to pull real runtime/genre data.
    // Best-effort: if it fails, the entry is still logged with estimates.
    Map<String, dynamic>? imported;
    final tmdbId = _tmdbId;
    if (tmdbId != null) {
      setState(() => _saving = true);
      try {
        imported = await _entertainmentApi.import(tmdbId, _type);
      } catch (_) {
        imported = null;
      }
      if (!mounted) return;
      setState(() => _saving = false);
    }

    if (!mounted) return;
    Navigator.pop(context, {
      'title': title,
      'note': _noteController.text.trim(),
      'type': _type,
      'status': _status,
      'rating': _rating,
      'season': _type == MediaType.show ? season : null,
      'watchedDate': _status == WatchStatus.watched ? DateTime.now() : null,
      'posterUrl': _posterUrl,
      'year': _year,
      'tmdbId': _tmdbId,
      'genres': (imported?['genres'] as List<dynamic>?)?.cast<String>(),
      'runtimeMinutes': imported?['runtime_minutes'] as int?,
      'episodeRuntimeMinutes': imported?['episode_runtime_minutes'] as int?,
      'numberOfEpisodes': imported?['number_of_episodes'] as int?,
      'numberOfSeasons': imported?['number_of_seasons'] as int?,
    });
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A22),
        title: const Text('Remove from log?', style: TextStyle(color: Colors.white)),
        content: Text(
          'This removes "${widget.entry?.title}" from your log. This can\'t be undone.',
          style: TextStyle(color: Colors.grey.shade400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.pop(context, {'action': 'delete'});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  _isEditing ? 'Edit Entry' : 'Log Title',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                if (_isEditing)
                  IconButton(
                    onPressed: _confirmDelete,
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.redAccent,
                    tooltip: 'Remove from log',
                  ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!_isGamesMode) ...[
              Text(
                'Type',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<MediaType>(
                segments: _allowedTypes
                    .map(
                      (t) => ButtonSegment(
                        value: t,
                        icon: Icon(t.icon),
                        label: Text(t.label),
                      ),
                    )
                    .toList(),
                selected: {_type},
                onSelectionChanged: (selection) {
                  setState(() {
                    _type = selection.first;
                    _pickedFromSearch = false;
                    _posterUrl = null;
                    _year = null;
                    _tmdbId = null;
                    _results = [];
                    _seasons = [];
                    _selectedSeason = null;
                    _cachedImport = null;
                  });
                  _runSearch(_titleController.text);
                },
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _titleController,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: _isGamesMode ? 'Title' : 'Search title',
                hintText: _isGamesMode
                    ? null
                    : 'Start typing to search TMDb…',
                prefixIcon: Icon(
                  _isGamesMode
                      ? Icons.sports_esports_outlined
                      : Icons.search,
                ),
                suffixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              onChanged: _onTitleChanged,
              onSubmitted: (_) => _submit(),
            ),
            if (!_isGamesMode && _pickedFromSearch && _year != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (_posterUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        _posterUrl!,
                        width: 36,
                        height: 54,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      'Selected: ${_titleController.text} ($_year)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.greenAccent.shade200,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (!_isGamesMode && _searchError != null) ...[
              const SizedBox(height: 8),
              Text(
                _searchError!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orangeAccent,
                ),
              ),
            ],
            if (!_isGamesMode && _results.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 260),
                decoration: BoxDecoration(
                  color: const Color(0xFF121218),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A35)),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey.shade800,
                  ),
                  itemBuilder: (context, index) {
                    final result = _results[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: 40,
                          height: 60,
                          child: result.posterUrl == null
                              ? ColoredBox(
                                  color: Colors.grey.shade900,
                                  child: Icon(
                                    result.type == MediaSearchType.show
                                        ? Icons.tv_outlined
                                        : Icons.movie_outlined,
                                    color: Colors.grey.shade600,
                                    size: 20,
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
                                      size: 18,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      title: Text(
                        result.displayTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: result.overview == null
                          ? null
                          : Text(
                              result.overview!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                      onTap: () => _selectResult(result),
                    );
                  },
                ),
              ),
            ],
            if (_type == MediaType.show) ...[
              const SizedBox(height: 12),
              Text(
                'Season',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 8),
              if (_tmdbId == null)
                TextField(
                  controller: _seasonController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Season',
                    prefixIcon: Icon(Icons.layers_outlined),
                  ),
                )
              else if (_loadingSeasons)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (_seasons.isEmpty)
                Text(
                  'Season data unavailable for this title.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                )
              else
                DropdownButtonFormField<int>(
                  initialValue: _selectedSeason,
                  dropdownColor: const Color(0xFF1A1A22),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.layers_outlined),
                  ),
                  items: _seasons.map((s) {
                    final seasonNumber = s['season_number'] as int;
                    final episodeCount = s['episode_count'] as int;
                    return DropdownMenuItem(
                      value: seasonNumber,
                      child: Text('Season $seasonNumber • $episodeCount episodes'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedSeason = value),
                ),
            ],
            const SizedBox(height: 16),
            Text(
              'Status',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<WatchStatus>(
              segments: WatchStatus.values
                  .map(
                    (s) => ButtonSegment(
                      value: s,
                      label: Text(s.label),
                    ),
                  )
                  .toList(),
              selected: {_status},
              onSelectionChanged: (selection) {
                setState(() => _status = selection.first);
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Rating',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (index) {
                  final starValue = index + 1;
                  final filled = _rating != null && starValue <= _rating!;
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _rating = filled && _rating == starValue
                            ? null
                            : starValue;
                      });
                    },
                    icon: Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: filled ? Colors.amber : Colors.grey.shade600,
                      size: 32,
                    ),
                  );
                }),
                if (_rating != null)
                  TextButton(
                    onPressed: () => setState(() => _rating = null),
                    child: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Save Changes' : 'Add to Log'),
            ),
          ],
        ),
      ),
    );
  }
}
