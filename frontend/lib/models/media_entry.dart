import 'package:flutter/material.dart';

/// MediaType categorizes the type of media being tracked.
/// - film: Movies (typically 2-3 hours)
/// - show: TV series (multiple seasons/episodes)
/// - game: Video games
enum MediaType {
  film('film'),
  show('show'),
  game('game');

  final String value;
  const MediaType(this.value);

  static MediaType fromString(String value) {
    return MediaType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Unknown MediaType: $value'),
    );
  }
}

/// WatchStatus represents the viewing/playing progress of a media item.
/// - watchlist: Added but not started yet
/// - watching: Currently in progress
/// - watched: Completed
enum WatchStatus { watchlist, watching, watched }

/// MediaEntry represents a single piece of media (movie, show, or game)
/// that the user wants to track in their personal library.
class MediaEntry {
  MediaEntry({
    /// Unique identifier for this entry (typically a UUID string)
    required this.id,
    /// Title of the media (e.g., "The Matrix", "Breaking Bad")
    required this.title,
    /// Type of media: film, show, or game
    required this.type,
    /// Current viewing/playing status (defaults to watchlist)
    this.status = WatchStatus.watchlist,
    /// User's rating from 1-5 stars (null if not rated yet)
    this.rating,
    /// Optional personal notes or review text
    this.note = '',
    /// For shows: which season the user watched (e.g., "Season 2")
    this.season,
    /// When this entry was added to the library
    required this.loggedAt,
    /// When the user finished watching/playing (null if not watched yet)
    this.watchedDate,
  });

  /// Unique identifier for this entry
  final String id;
  /// Title of the media
  final String title;
  /// What type of media this is
  final MediaType type;
  /// Current status in the user's library
  final WatchStatus status;
  /// Rating on a 1-5 scale (or null)
  final int? rating;
  /// User's personal notes
  final String note;
  /// Season number (if applicable for shows)
  final int? season;
  /// Timestamp of when this was logged
  final DateTime loggedAt;
  /// When it was completed (if applicable)
  final DateTime? watchedDate;

  /// copyWith creates a modified copy of this entry.
  /// This is useful for updating specific fields without recreating the entire object.
  /// The clearX flags allow explicitly setting nullable fields to null.
  MediaEntry copyWith({
    String? title,
    MediaType? type,
    WatchStatus? status,
    int? rating,
    String? note,
    int? season,
    DateTime? watchedDate,
    // Flags to explicitly clear nullable fields (set them to null)
    bool clearRating = false,
    bool clearSeason = false,
    bool clearWatchedDate = false,
  }) {
    return MediaEntry(
      // ID never changes for an existing entry
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      // Use clearRating flag to allow setting rating to null
      // Otherwise use provided rating or keep current value
      rating: clearRating ? null : (rating ?? this.rating),
      note: note ?? this.note,
      season: clearSeason ? null : (season ?? this.season),
      // loggedAt never changes after creation
      loggedAt: loggedAt,
      watchedDate:
          clearWatchedDate ? null : (watchedDate ?? this.watchedDate),
    );
  }
}

/// Extension on MediaType to add helper properties.
/// Extensions allow adding methods to existing classes without modifying them.
extension MediaTypeX on MediaType {
  /// User-friendly label for displaying the media type in the UI.
  String get label {
    switch (this) {
      case MediaType.film:
        return 'Film';
      case MediaType.show:
        return 'Show';
      case MediaType.game:
        return 'Game';
    }
  }

  /// IconData returns the appropriate Material icon for this media type.
  /// Used in tiles and UI elements to visually represent the type.
  IconData get icon {
    switch (this) {
      case MediaType.film:
        return Icons.movie_outlined;
      case MediaType.show:
        return Icons.tv_outlined;
      case MediaType.game:
        return Icons.sports_esports_outlined;
    }
  }
}

/// Extension on WatchStatus to add helper properties.
extension WatchStatusX on WatchStatus {
  /// User-friendly label for displaying the status in the UI.
  String get label {
    switch (this) {
      case WatchStatus.watchlist:
        return 'Watchlist';
      case WatchStatus.watching:
        return 'Watching';
      case WatchStatus.watched:
        return 'Watched';
    }
  }
}

/// Formats a DateTime into a short, readable date string.
/// Example: "Jan 15, 2024"
/// Used when displaying when a user finished watching something.
String formatShortDate(DateTime date) {
  // Abbreviated month names
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  // Format: "Month Day, Year" (month is 1-indexed, so subtract 1)
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

/// Approximate watch time in minutes for films/shows.
/// Film ≈ 2h. Show ≈ seasons × 10 episodes × 45m.
extension MediaEntryScreenTimeX on MediaEntry {
  static const int filmMinutes = 120;
  static const int showEpisodesPerSeason = 10;
  static const int showEpisodeMinutes = 45;

  int get approxScreenMinutes {
    switch (type) {
      case MediaType.film:
        return filmMinutes;
      case MediaType.show:
        final seasons = season ?? 1;
        return seasons * showEpisodesPerSeason * showEpisodeMinutes;
      case MediaType.game:
        return 0;
    }
  }
}

/// Sums approx screen time for film & show entries in the library.
int approxMoviesScreenMinutes(Iterable<MediaEntry> entries) {
  return entries
      .where((e) => e.type == MediaType.film || e.type == MediaType.show)
      .fold(0, (sum, e) => sum + e.approxScreenMinutes);
}

String formatScreenTime(int totalMinutes) {
  if (totalMinutes <= 0) return '—';
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours == 0) return '${minutes}m';
  if (minutes == 0) return '${hours}h';
  return '${hours}h ${minutes}m';
}
