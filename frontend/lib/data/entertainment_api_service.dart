import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/media_entry.dart';
import '../models/media_search_result.dart';

enum DiscoverSort { popularity, rating, newest }

/// Talks to the NestJS backend's TMDB-backed entertainment endpoints.
/// Override the target with:
/// `flutter run --dart-define=BACKEND_URL=https://your-api.example.com`
class EntertainmentApiService {
  EntertainmentApiService({http.Client? client, String? backendUrl})
      : _client = client ?? http.Client(),
        _backendUrl = backendUrl ??
            const String.fromEnvironment(
              'BACKEND_URL',
              defaultValue: 'http://localhost:3000',
            );

  final http.Client _client;
  final String _backendUrl;

  Future<List<MediaSearchResult>> search(String query, MediaType type) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final typeParam = type == MediaType.show ? 'show' : 'film';
    final uri = Uri.parse('$_backendUrl/entertainment/search/tmdb').replace(
      queryParameters: {'query': trimmed, 'type': typeParam},
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Search failed (${response.statusCode})');
    }

    final results = jsonDecode(response.body) as List<dynamic>;
    return results
        .map((raw) => _mapResult(raw as Map<String, dynamic>))
        .whereType<MediaSearchResult>()
        .take(8)
        .toList();
  }

  MediaSearchResult? _mapResult(Map<String, dynamic> json) {
    final externalId = json['external_id'] as String?;
    final title = json['title'] as String?;
    if (externalId == null || title == null || title.trim().isEmpty) {
      return null;
    }

    final tmdbId = int.tryParse(externalId);
    if (tmdbId == null) return null;

    final isShow = json['type'] == 'show';
    final date = json['release_date'] as String?;

    return MediaSearchResult(
      tmdbId: tmdbId,
      title: title.trim(),
      type: isShow ? MediaSearchType.show : MediaSearchType.film,
      year: _yearFromDate(date),
      posterUrl: json['poster'] as String?,
      overview: (json['description'] as String?)?.trim(),
    );
  }

  int? _yearFromDate(String? date) {
    if (date == null || date.length < 4) return null;
    return int.tryParse(date.substring(0, 4));
  }

  /// Recommendations for [type], filtered by [genres] (TMDB genre names —
  /// matches ANY of them, not all). Falls back to TMDB's "popular" list when
  /// [genres] is empty. Excludes R18+/X18+/RC-tier content; pass [page] to
  /// load further pages and [sort] to change ordering.
  Future<List<MediaSearchResult>> discover({
    required MediaType type,
    List<String> genres = const [],
    int page = 1,
    DiscoverSort sort = DiscoverSort.popularity,
  }) async {
    final typeParam = type == MediaType.show ? 'show' : 'film';
    final uri = Uri.parse('$_backendUrl/entertainment/discover/tmdb').replace(
      queryParameters: {
        'type': typeParam,
        'page': '$page',
        'sort': sort.name,
        if (genres.isNotEmpty) 'genres': genres.join(','),
      },
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Discover failed (${response.statusCode})');
    }

    final results = jsonDecode(response.body) as List<dynamic>;
    return results
        .map((raw) => _mapResult(raw as Map<String, dynamic>))
        .whereType<MediaSearchResult>()
        .toList();
  }

  /// All TMDB genre names for [type] — used to populate a genre filter UI.
  Future<List<String>> genres(MediaType type) async {
    final typeParam = type == MediaType.show ? 'show' : 'film';
    final uri = Uri.parse('$_backendUrl/entertainment/genres/tmdb').replace(
      queryParameters: {'type': typeParam},
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load genres (${response.statusCode})');
    }

    return (jsonDecode(response.body) as List<dynamic>).cast<String>();
  }

  /// Imports a picked TMDB result into the shared catalog on the backend.
  /// Safe to call more than once for the same title (returns the existing row).
  /// The returned map includes real runtime/genre data pulled from TMDB.
  Future<Map<String, dynamic>> import(int tmdbId, MediaType type) async {
    final typeParam = type == MediaType.show ? 'show' : 'film';
    final uri = Uri.parse('$_backendUrl/entertainment/import/tmdb');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'tmdbId': '$tmdbId', 'type': typeParam}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Import failed (${response.statusCode})');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
