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
  // GETTERS (UNTUK UI)
  // ════════════════════════════════════════════════

  // Menghubungkan variabel internal ke nama yang sering dipanggil di UI
  String get videoUrl => fullVideoUrl ?? trailerUrl ?? '';

  bool get isPremium => contentAccess?.toUpperCase() == 'PREMIUM';

  // ════════════════════════════════════════════════
  // FACTORY FROM JSON (DARI DATABASE KE FLUTTER)
  // ════════════════════════════════════════════════
  factory Movie.fromJson(Map<String, dynamic> j) => Movie(
    id: j['id'],
    title: j['title'] ?? '',
    description: j['description'],
    // Mengambil dari snake_case MySQL (image_4d4c89.png)
    thumbnailUrl: j['thumbnail_url'],
    bannerUrl: j['banner_url'],
    trailerUrl: j['trailer_url'],
    fullVideoUrl: j['full_video_url'],
    releaseYear: j['release_year'],
    duration: j['duration'],
    ageRating: j['age_rating'],
    contentType: j['content_type'],
    contentAccess: j['content_access'],
    rating: (j['rating'] as num?)?.toDouble(),
    isFeatured: j['is_featured'] == 1 || j['is_featured'] == true,
    isTrending: j['is_trending'] == 1 || j['is_trending'] == true,
    viewCount: j['view_count'] ?? 0,
    genres: j['genres'] != null
        ? (j['genres'] as List).map((g) => Genre.fromJson(g)).toList()
        : null,
  );

  // ════════════════════════════════════════════════
  // TO JSON (DARI FLUTTER KE DATABASE/API)
  // ════════════════════════════════════════════════
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'thumbnail_url': thumbnailUrl,
    'banner_url': bannerUrl,
    'trailer_url': trailerUrl,
    'full_video_url': fullVideoUrl,
    'release_year': releaseYear,
    'duration': duration,
    'rating': rating,
    'age_rating': ageRating,
    'content_type': contentType,
    'content_access': contentAccess,
    'is_featured': isFeatured ? 1 : 0,
    'is_trending': isTrending ? 1 : 0,
  };
}

class Genre {
  final int id;
  final String name;
  final String? icon;

  const Genre({required this.id, required this.name, this.icon});

  factory Genre.fromJson(Map<String, dynamic> j) => Genre(
      id: j['id'],
      name: j['name'] ?? '',
      icon: j['icon']
  );
}