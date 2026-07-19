import 'package:flutter/material.dart';
import '../models/entertainment.dart';
import '../models/media_type.dart';
import '../services/api_service.dart';

class EntertainmentProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<Entertainment> _entertainments = [];
  bool _isLoading = false;
  String? _error;

  EntertainmentProvider(this._apiService);

  List<Entertainment> get entertainments => _entertainments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getAllEntertainment();
      _entertainments = (response as List)
          .map((item) => Entertainment.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEntertainment({
    required String title,
    required MediaType type,
    String? description,
    String? poster,
    DateTime? releaseDate,
    List<String>? genres,
    String? developer,
    String? studio,
    double? rating,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newItem = Entertainment(
        title: title,
        type: type,
        description: description,
        poster: poster,
        releaseDate: releaseDate,
        genres: genres,
        developer: developer,
        studio: studio,
        rating: rating,
      );

      final response = await _apiService.createEntertainment(newItem.toJson());
      final created = Entertainment.fromJson(response as Map<String, dynamic>);
      _entertainments.add(created);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateEntertainment(String id, {
    String? title,
    MediaType? type,
    String? description,
    String? poster,
    DateTime? releaseDate,
    List<String>? genres,
    String? developer,
    String? studio,
    double? rating,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (type != null) data['type'] = type.value;
      if (description != null) data['description'] = description;
      if (poster != null) data['poster'] = poster;
      if (releaseDate != null) data['release_date'] = releaseDate.toIso8601String();
      if (genres != null) data['genres'] = genres;
      if (developer != null) data['developer'] = developer;
      if (studio != null) data['studio'] = studio;
      if (rating != null) data['rating'] = rating;

      final response = await _apiService.updateEntertainment(id, data);
      final updated = Entertainment.fromJson(response as Map<String, dynamic>);

      final index = _entertainments.indexWhere((item) => item.id == id);
      if (index != -1) {
        _entertainments[index] = updated;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEntertainment(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deleteEntertainment(id);
      _entertainments.removeWhere((item) => item.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
