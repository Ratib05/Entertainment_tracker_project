import 'package:flutter/material.dart';

/// MediaType categorizes the type of media being tracked.
/// - film: Movies (typically 2-3 hours)
/// - show: TV series (multiple seasons/episodes)
/// - game: Video games
enum MediaType { film, show, game }

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
    this.posterUrl,
    this.year,
    this.tmdbId,
    this.genres = const [],
    this.runtimeMinutes,
    this.episodeRuntimeMinutes,
    this.numberOfEpisodes,
    this.numberOfSeasons,
    this.lastWatchedMinutes,
    this.seasonEpisodeCount,
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
  final String? posterUrl;
  final int? year;
  final int? tmdbId;
  /// Genre names from TMDB (populated when added via search).
  final List<String> genres;
  /// Real movie runtime in minutes, from TMDB (film only).
  final int? runtimeMinutes;
  /// Real average episode runtime in minutes, from TMDB (show only).
  final int? episodeRuntimeMinutes;
  /// Total episode count across the whole series, from TMDB (show only).
  final int? numberOfEpisodes;
  /// Total season count across the whole series, from TMDB (show only).
  final int? numberOfSeasons;
  /// How many minutes into the film/season the user has watched so far.
  /// Only meaningful while status is [WatchStatus.watching].
  final int? lastWatchedMinutes;
  /// Real episode count for the specific season selected, from TMDB (show
  /// only). Used instead of the averaged episodes-per-season estimate.
  final int? seasonEpisodeCount;

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
    String? posterUrl,
    int? year,
    int? tmdbId,
    List<String>? genres,
    int? runtimeMinutes,
    int? episodeRuntimeMinutes,
    int? numberOfEpisodes,
    int? numberOfSeasons,
    int? lastWatchedMinutes,
    int? seasonEpisodeCount,
    bool clearRating = false,
    bool clearSeason = false,
    bool clearWatchedDate = false,
    bool clearPosterUrl = false,
    bool clearYear = false,
    bool clearTmdbId = false,
    bool clearLastWatchedMinutes = false,
  }) {
    return MediaEntry(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      rating: clearRating ? null : (rating ?? this.rating),
      note: note ?? this.note,
      season: clearSeason ? null : (season ?? this.season),
      loggedAt: loggedAt,
      watchedDate:
          clearWatchedDate ? null : (watchedDate ?? this.watchedDate),
      posterUrl: clearPosterUrl ? null : (posterUrl ?? this.posterUrl),
      year: clearYear ? null : (year ?? this.year),
      tmdbId: clearTmdbId ? null : (tmdbId ?? this.tmdbId),
      genres: genres ?? this.genres,
      runtimeMinutes: runtimeMinutes ?? this.runtimeMinutes,
      episodeRuntimeMinutes: episodeRuntimeMinutes ?? this.episodeRuntimeMinutes,
      numberOfEpisodes: numberOfEpisodes ?? this.numberOfEpisodes,
      numberOfSeasons: numberOfSeasons ?? this.numberOfSeasons,
      lastWatchedMinutes: clearLastWatchedMinutes
          ? null
          : (lastWatchedMinutes ?? this.lastWatchedMinutes),
      seasonEpisodeCount: seasonEpisodeCount ?? this.seasonEpisodeCount,
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

/// Screen time in minutes for films/shows, driven by watch status:
/// - watchlist: not started yet, so 0.
/// - watching: however far the user says they've gotten ([lastWatchedMinutes]).
/// - watched: the full runtime.
/// Uses real TMDB runtime/episode-count data when available (set on
/// import); falls back to rough estimates for titles added manually
/// without a TMDB match.
extension MediaEntryScreenTimeX on MediaEntry {
  static const int fallbackFilmMinutes = 120;
  static const int fallbackShowEpisodesPerSeason = 10;
  static const int fallbackShowEpisodeMinutes = 45;

  int get _fullRuntimeMinutes {
    switch (type) {
      case MediaType.film:
        return runtimeMinutes ?? fallbackFilmMinutes;
      case MediaType.show:
        final episodeMinutes = episodeRuntimeMinutes ?? fallbackShowEpisodeMinutes;

        // Prefer the real episode count for the specific season logged;
        // fall back to an averaged estimate if that's not available.
        final totalEpisodes = numberOfEpisodes;
        final totalSeasons = numberOfSeasons;
        final episodesPerSeason = (totalEpisodes != null &&
                totalSeasons != null &&
                totalSeasons > 0)
            ? (totalEpisodes / totalSeasons).round()
            : fallbackShowEpisodesPerSeason;

        final episodes = seasonEpisodeCount ?? ((season ?? 1) * episodesPerSeason);
        return episodes * episodeMinutes;
      case MediaType.game:
        return 0;
    }
  }

  int get approxScreenMinutes {
    if (type == MediaType.game) return 0;

    switch (status) {
      case WatchStatus.watchlist:
        return 0;
      case WatchStatus.watching:
        return (lastWatchedMinutes ?? 0).clamp(0, _fullRuntimeMinutes);
      case WatchStatus.watched:
        return _fullRuntimeMinutes;
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
