import 'media_entry.dart';

class Entertainment {
  final String? id;
  final String title;
  final MediaType type;
  final String? description;
  final String? poster;
  final DateTime? releaseDate;
  final List<String>? genres;
  final String? developer;
  final String? studio;
  final double? rating;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Entertainment({
    this.id,
    required this.title,
    required this.type,
    this.description,
    this.poster,
    this.releaseDate,
    this.genres,
    this.developer,
    this.studio,
    this.rating,
    this.createdAt,
    this.updatedAt,
  });

  factory Entertainment.fromJson(Map<String, dynamic> json) {
    return Entertainment(
      id: json['id'] as String?,
      title: json['title'] as String,
      type: MediaType.fromString(json['type'] as String),
      description: json['description'] as String?,
      poster: json['poster'] as String?,
      releaseDate: json['release_date'] != null
          ? DateTime.parse(json['release_date'] as String)
          : null,
      genres: json['genres'] != null
          ? List<String>.from(json['genres'] as List)
          : null,
      developer: json['developer'] as String?,
      studio: json['studio'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type.value,
      'description': description,
      'poster': poster,
      'release_date': releaseDate?.toIso8601String(),
      'genres': genres,
      'developer': developer,
      'studio': studio,
      'rating': rating,
    };
  }

  Entertainment copyWith({
    String? id,
    String? title,
    MediaType? type,
    String? description,
    String? poster,
    DateTime? releaseDate,
    List<String>? genres,
    String? developer,
    String? studio,
    double? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Entertainment(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      description: description ?? this.description,
      poster: poster ?? this.poster,
      releaseDate: releaseDate ?? this.releaseDate,
      genres: genres ?? this.genres,
      developer: developer ?? this.developer,
      studio: studio ?? this.studio,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
