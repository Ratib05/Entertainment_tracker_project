import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/media_entry.dart';
import '../models/tracker_mode.dart';

/// AddMediaSheet is a modal bottom sheet for creating or editing media entries.
/// It handles the full form for logging a new movie, show, or game.
class AddMediaSheet extends StatefulWidget {
  const AddMediaSheet({
    super.key,
    /// The current tracker mode (movies or games) - determines which fields to show
    required this.mode,
    /// Optional existing entry - if provided, this becomes an edit form instead of create
    this.entry,
  });

  final TrackerMode mode;
  final MediaEntry? entry;

  @override
  State<AddMediaSheet> createState() => _AddMediaSheetState();
}

class _AddMediaSheetState extends State<AddMediaSheet> {
  // ========== TEXT CONTROLLERS ==========
  // These manage the input text for various fields
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late final TextEditingController _seasonController;

  // ========== FORM STATE ==========
  // These hold the current values of form fields
  late MediaType _type; // What kind of media (film/show/game)
  late WatchStatus _status; // Current viewing status
  int? _rating; // 1-5 star rating (nullable)

  // ========== CONVENIENCE GETTERS ==========
  /// Check if we're editing an existing entry (vs creating a new one)
  bool get _isEditing => widget.entry != null;
  
  /// Check if we're in games mode (vs movies mode)
  bool get _isGamesMode => widget.mode == TrackerMode.games;

  /// Get the list of allowed media types for the current mode.
  /// Games mode only allows games, movies mode allows films and shows.
  List<MediaType> get _allowedTypes => _isGamesMode
      ? const [MediaType.game]
      : const [MediaType.film, MediaType.show];

  @override
  void initState() {
    super.initState();
    
    // Pre-populate form with existing data if editing
    final entry = widget.entry;
    
    // Initialize text controllers with existing values or empty strings
    _titleController = TextEditingController(text: entry?.title ?? '');
    _noteController = TextEditingController(text: entry?.note ?? '');
    _seasonController = TextEditingController(
      text: entry?.season?.toString() ?? '',
    );
    
    // Set initial media type: use existing or default based on mode
    _type = entry?.type ?? (_isGamesMode ? MediaType.game : MediaType.film);
    
    // Ensure the type is allowed in current mode
    if (!_allowedTypes.contains(_type)) {
      _type = _allowedTypes.first;
    }
    
    // Set initial status and rating from existing entry
    _status = entry?.status ?? WatchStatus.watchlist;
    _rating = entry?.rating;
  }

  @override
  void dispose() {
    // Clean up text controllers to prevent memory leaks
    _titleController.dispose();
    _noteController.dispose();
    _seasonController.dispose();
    super.dispose();
  }

  /// _submit validates the form and returns the data to the parent screen.
  /// Pops the bottom sheet with a map containing all the form data.
  void _submit() {
    // Title is required - don't submit if empty
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    // Parse season number, or null if empty
    final seasonText = _seasonController.text.trim();
    final season = seasonText.isEmpty ? null : int.tryParse(seasonText);

    // Return all form data to the parent screen as a map
    Navigator.pop(context, {
      'title': title,
      'note': _noteController.text.trim(),
      'type': _type,
      'status': _status,
      'rating': _rating,
      // Only include season for shows
      'season': _type == MediaType.show ? season : null,
      // Auto-set watched date to now if marking as watched
      'watchedDate': _status == WatchStatus.watched ? DateTime.now() : null,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Get keyboard height to adjust bottom padding (bottom sheet pushes up when keyboard appears)
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      // Adjust padding based on keyboard height
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        // Allow scrolling if content exceeds screen height
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ========== HEADER WITH TITLE & CLOSE BUTTON ==========
            Row(
              children: [
                // Title changes based on edit vs create
                Text(
                  _isEditing ? 'Edit Entry' : 'Log Title',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                // Close button to dismiss without saving
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ========== TITLE INPUT FIELD ==========
            TextField(
              controller: _titleController,
              // Auto-focus when creating new entry (but not when editing)
              autofocus: !_isEditing,
              // Capitalize first letter of each word
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Title',
                // Icon changes based on mode (movie or game icon)
                prefixIcon: Icon(
                  _isGamesMode
                      ? Icons.sports_esports_outlined
                      : Icons.movie_outlined,
                ),
              ),
              // Submit form when user hits done/enter on keyboard
              onSubmitted: (_) => _submit(),
            ),

            // ========== MEDIA TYPE SELECTOR (MOVIES MODE ONLY) ==========
            // Only show type toggle in movies mode (games mode only has one type)
            if (!_isGamesMode) ...[
              const SizedBox(height: 12),
              // Label for the section
              Text(
                'Type',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 8),
              // Segmented button to toggle between Film and Show
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
                  setState(() => _type = selection.first);
                },
              ),
            ],

            // ========== SEASON INPUT (TV SHOWS ONLY) ==========
            // Only show season field when media type is Show
            if (_type == MediaType.show) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _seasonController,
                // Only allow numeric input
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Season (optional)',
                  prefixIcon: Icon(Icons.layers_outlined),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // ========== STATUS SELECTOR ==========
            // Section label
            Text(
              'Status',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 8),
            // Segmented button for watchlist/watching/watched
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

            // ========== STAR RATING INPUT ==========
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
                // Generate 5 clickable stars
                ...List.generate(5, (index) {
                  final starValue = index + 1;
                  // Check if this star should be filled
                  final filled = _rating != null && starValue <= _rating!;
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        // Clicking a filled star deselects all stars (toggle)
                        // Clicking an unfilled star sets rating to that value
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
                // Show clear button if a rating is set
                if (_rating != null)
                  TextButton(
                    onPressed: () => setState(() => _rating = null),
                    child: const Text('Clear'),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // ========== NOTES/REVIEW TEXT FIELD ==========
            TextField(
              controller: _noteController,
              textCapitalization: TextCapitalization.sentences,
              // Allow multiple lines for longer reviews
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.notes_outlined),
                // Align label with input text (not at top)
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 20),

            // ========== SUBMIT BUTTON ==========
            // Large button to submit the form
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              // Button text changes based on edit vs create
              child: Text(_isEditing ? 'Save Changes' : 'Add to Log'),
            ),
          ],
        ),
      ),
    );
  }
}
