import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/media_entry.dart';
import '../models/media_search_result.dart';

/// Searches TMDb for films/shows. Pass key via:
/// `flutter run --dart-define=TMDB_API_KEY=your_key`
class TmdbSearchService {
  TmdbSearchService({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        _apiKey = apiKey ??
            const String.fromEnvironment('TMDB_API_KEY', defaultValue: '');

  static const _base = 'https://api.themoviedb.org/3';
  static const _imageBase = 'https://image.tmdb.org/t/p/w185';

  final http.Client _client;
  final String _apiKey;

  bool get hasApiKey => _apiKey.isNotEmpty;

  Future<List<MediaSearchResult>> search(String query, MediaType type) async {
    final trimmed = query.trim();
    if (!hasApiKey || trimmed.length < 2) return [];

    final path = type == MediaType.show ? '/search/tv' : '/search/movie';
    final uri = Uri.parse('$_base$path').replace(
      queryParameters: {
        'api_key': _apiKey,
        'query': trimmed,
        'include_adult': 'false',
        'language': 'en-US',
        'page': '1',
      },
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('TMDb search failed (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>? ?? [];

    return results
        .map((raw) => _mapResult(raw as Map<String, dynamic>, type))
        .whereType<MediaSearchResult>()
        .take(8)
        .toList();
  }

  MediaSearchResult? _mapResult(Map<String, dynamic> json, MediaType type) {
    final id = json['id'] as int?;
    if (id == null) return null;

    final isShow = type == MediaType.show;
    final title = (isShow ? json['name'] : json['title']) as String?;
    if (title == null || title.trim().isEmpty) return null;

    final date =
        (isShow ? json['first_air_date'] : json['release_date']) as String?;
    final year = _yearFromDate(date);
    final posterPath = json['poster_path'] as String?;
    final overview = json['overview'] as String?;

    return MediaSearchResult(
      tmdbId: id,
      title: title.trim(),
      type: isShow ? MediaSearchType.show : MediaSearchType.film,
      year: year,
      posterUrl: posterPath == null ? null : '$_imageBase$posterPath',
      overview: overview?.trim().isEmpty == true ? null : overview?.trim(),
    );
  }

  int? _yearFromDate(String? date) {
    if (date == null || date.length < 4) return null;
    return int.tryParse(date.substring(0, 4));
  }
}
