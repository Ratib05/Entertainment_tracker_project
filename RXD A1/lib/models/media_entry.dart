import 'package:flutter/material.dart';

enum MediaType { film, show }

enum WatchStatus { watchlist, watching, watched }

enum MediaFilter { all, films, shows, watchlist, watched }

class MediaEntry {
  MediaEntry({
    required this.id,
    required this.title,
    required this.type,
    this.status = WatchStatus.watchlist,
    this.rating,
    this.note = '',
    this.season,
    required this.loggedAt,
    this.watchedDate,
  });

  final String id;
  final String title;
  final MediaType type;
  final WatchStatus status;
  final int? rating;
  final String note;
  final int? season;
  final DateTime loggedAt;
  final DateTime? watchedDate;

  MediaEntry copyWith({
    String? title,
    MediaType? type,
    WatchStatus? status,
    int? rating,
    String? note,
    int? season,
    DateTime? watchedDate,
    bool clearRating = false,
    bool clearSeason = false,
    bool clearWatchedDate = false,
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
    );
  }
}

extension MediaTypeX on MediaType {
  String get label => this == MediaType.film ? 'Film' : 'Show';

  IconData get icon =>
      this == MediaType.film ? Icons.movie_outlined : Icons.tv_outlined;
}

extension WatchStatusX on WatchStatus {
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

String formatShortDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
