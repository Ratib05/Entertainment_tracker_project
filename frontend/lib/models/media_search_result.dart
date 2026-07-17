class MediaSearchResult {
  const MediaSearchResult({
    required this.tmdbId,
    required this.title,
    required this.type,
    this.year,
    this.posterUrl,
    this.overview,
  });

  final int tmdbId;
  final String title;
  final MediaSearchType type;
  final int? year;
  final String? posterUrl;
  final String? overview;

  String get displayTitle {
    if (year == null) return title;
    return '$title ($year)';
  }
}

enum MediaSearchType { film, show }
