import 'package:flutter/foundation.dart';

class Movie {
  final int id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String? bannerUrl;
  final String? trailerUrl;
  final String? fullVideoUrl;
  final int? releaseYear;
  final String? duration;
  final String? ageRating;
  final String? contentType;
  final String? contentAccess;
  final double? rating;
  final bool isFeatured;
  final bool isTrending;
  final int viewCount;
  final List<Genre>? genres;

  const Movie({
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.bannerUrl,
    this.trailerUrl,
    this.fullVideoUrl,
    this.releaseYear,
    this.duration,
    this.ageRating,
    this.contentType,
    this.contentAccess,
    this.rating,
    this.isFeatured = false,
    this.isTrending = false,
    this.viewCount = 0,
    this.genres,
  });

  // ════════════════════════════════════════════════
  // GETTERS
  // ════════════════════════════════════════════════
  String get videoUrl => fullVideoUrl ?? trailerUrl ?? '';
  bool get isPremium => contentAccess?.toUpperCase() == 'PREMIUM';

  // ════════════════════════════════════════════════
  // FROM JSON — pakai camelCase sesuai response Spring Boot
  // ════════════════════════════════════════════════
  factory Movie.fromJson(Map<String, dynamic> j) {
    return Movie(
      id: j['id'] is String ? int.parse(j['id']) : (j['id'] ?? 0),
      title: j['title']?.toString() ?? '',
      description: j['description']?.toString(),

      // ✅ camelCase — sesuai response backend Spring Boot
      thumbnailUrl: j['thumbnailUrl']?.toString(),
      bannerUrl:    j['bannerUrl']?.toString(),
      trailerUrl:   j['trailerUrl']?.toString(),
      fullVideoUrl: j['fullVideoUrl']?.toString(),

      releaseYear: j['releaseYear'] is String
          ? int.tryParse(j['releaseYear'])
          : j['releaseYear'],
      duration:    j['duration']?.toString(),
      ageRating:   j['ageRating']?.toString(),
      contentType:   j['contentType']?.toString(),
      contentAccess: j['contentAccess']?.toString(),

      rating: (j['rating'] as num?)?.toDouble(),

      isFeatured: j['isFeatured'] == 1 || j['isFeatured'] == true || j['isFeatured'] == '1',
      isTrending: j['isTrending'] == 1 || j['isTrending'] == true || j['isTrending'] == '1',

      viewCount: j['viewCount'] is String
          ? int.tryParse(j['viewCount']) ?? 0
          : (j['viewCount'] ?? 0),

      genres: j['genres'] != null
          ? (j['genres'] as List).map((g) => Genre.fromJson(g)).toList()
          : null,
    );
  }

  // ════════════════════════════════════════════════
  // TO JSON — untuk kirim data ke backend
  // ════════════════════════════════════════════════
  Map<String, dynamic> toJson() => {
    'id':            id,
    'title':         title,
    'description':   description,
    'thumbnailUrl':  thumbnailUrl,
    'bannerUrl':     bannerUrl,
    'trailerUrl':    trailerUrl,
    'fullVideoUrl':  fullVideoUrl,
    'releaseYear':   releaseYear,
    'duration':      duration,
    'rating':        rating,
    'ageRating':     ageRating,
    'contentType':   contentType,
    'contentAccess': contentAccess,
    'isFeatured':    isFeatured,
    'isTrending':    isTrending,
    'viewCount':     viewCount,
  };
}

class Genre {
  final int id;
  final String name;
  final String? icon;

  const Genre({required this.id, required this.name, this.icon});

  factory Genre.fromJson(Map<String, dynamic> j) => Genre(
    id:   j['id'] is String ? int.parse(j['id']) : (j['id'] ?? 0),
    name: j['name']?.toString() ?? '',
    icon: j['icon']?.toString(),
  );
}