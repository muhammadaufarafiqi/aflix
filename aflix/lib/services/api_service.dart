import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = kIsWeb
      ? 'http://localhost:8080/api'
      : 'http://10.0.2.2:8080/api';

  String? _token;
  void setToken(String? t) => _token = t;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // --- AUTH ---
  Future<UserModel> login(String email, String password) async {
    final r = await http.post(Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}));
    if (r.statusCode == 200) return UserModel.fromJson(jsonDecode(r.body));
    throw Exception(r.body.isNotEmpty ? r.body : 'Login gagal');
  }

  Future<UserModel> register(String name, String email, String password) async {
    final r = await http.post(Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode({'name': name, 'email': email, 'password': password}));
    if (r.statusCode == 200) return UserModel.fromJson(jsonDecode(r.body));
    throw Exception(r.body.isNotEmpty ? r.body : 'Registrasi gagal');
  }

  // --- USER PROFILE ---
  Future<Map<String, dynamic>> getMyProfile() async {
    final r = await http.get(Uri.parse('$baseUrl/users/me'), headers: _headers);
    if (r.statusCode == 200) return Map<String, dynamic>.from(jsonDecode(r.body));
    throw Exception('Gagal mengambil data profil');
  }

  Future<bool> updateMyProfile({
    required String name,
    required String email,
    String? password,
  }) async {
    final Map<String, dynamic> body = {'name': name, 'email': email};
    if (password != null && password.isNotEmpty) body['password'] = password;
    final r = await http.put(Uri.parse('$baseUrl/users/update'),
        headers: _headers, body: jsonEncode(body));
    return r.statusCode == 200;
  }

  // --- MOVIES ---
  Future<List<Movie>> _getMovies(String path) async {
    try {
      final r = await http.get(Uri.parse('$baseUrl$path'), headers: _headers);
      if (r.statusCode == 200) {
        final List<dynamic> data = jsonDecode(r.body); // Tambahan: Pastikan ini List
        return data.map((e) => Movie.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching movies: $e');
    }
    return [];
  }

  Future<List<Movie>> getAllMovies()   => _getMovies('/movies');
  Future<List<Movie>> getFeatured()    => _getMovies('/movies/featured');
  Future<List<Movie>> getTrending()    => _getMovies('/movies/trending');
  Future<List<Movie>> getNewReleases() => _getMovies('/movies/new-releases');
  Future<List<Movie>> getTopViewed()   => _getMovies('/movies/top-viewed');
  Future<List<Movie>> search(String q) =>
      _getMovies('/movies/search?q=${Uri.encodeComponent(q)}');

  Future<Movie?> getMovieById(int id) async {
    try {
      final r = await http.get(Uri.parse('$baseUrl/movies/$id'), headers: _headers);
      if (r.statusCode == 200) {
        final dynamic data = jsonDecode(r.body);
        // Tambahan: Pastikan data bukan string kosong atau null sebelum di-parse
        if (data != null) {
          return Movie.fromJson(data as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('Error getMovieById: $e');
    }
    return null;
  }

  // --- FAVORITES ---
  Future<List<Movie>> getFavorites() => _getMovies('/favorites');

  Future<void> toggleFavorite(int movieId) async {
    await http.post(Uri.parse('$baseUrl/favorites/$movieId'), headers: _headers);
  }

  Future<bool> checkFavoriteStatus(int movieId) async {
    final r = await http.get(
        Uri.parse('$baseUrl/favorites/$movieId/status'), headers: _headers);
    if (r.statusCode == 200) {
      final result = jsonDecode(r.body);
      return result is bool ? result : false; // Tambahan: Cek tipe data
    }
    return false;
  }

  // --- DOWNLOADS ✅ ---
  Future<List<Movie>> getDownloads() => _getMovies('/downloads');

  Future<void> addDownload(int movieId) async {
    try {
      await http.post(
          Uri.parse('$baseUrl/downloads/$movieId'), headers: _headers);
    } catch (e) {
      debugPrint('Error addDownload: $e');
    }
  }

  Future<void> removeDownload(int movieId) async {
    try {
      await http.delete(
          Uri.parse('$baseUrl/downloads/$movieId'), headers: _headers);
    } catch (e) {
      debugPrint('Error removeDownload: $e');
    }
  }

  Future<bool> checkDownloadStatus(int movieId) async {
    try {
      final r = await http.get(
          Uri.parse('$baseUrl/downloads/$movieId/status'), headers: _headers);
      if (r.statusCode == 200) {
        final result = jsonDecode(r.body);
        return result is bool ? result : false;
      }
    } catch (e) {
      debugPrint('Error checkDownloadStatus: $e');
    }
    return false;
  }

  // --- VIDEO PLAYER ---
  Future<void> trackView(int id) async {
    try {
      await http.post(Uri.parse('$baseUrl/movies/$id/view'), headers: _headers);
    } catch (e) {
      debugPrint('Error trackView: $e');
    }
  }

  Future<void> saveProgress(int id, int seconds) async {
    try {
      final r = await http.post(
          Uri.parse('$baseUrl/movies/$id/progress?seconds=$seconds'),
          headers: _headers);
      if (r.statusCode != 200) debugPrint('Gagal simpan progress: ${r.body}');
    } catch (e) {
      debugPrint('Error saveProgress: $e');
    }
  }

  // --- ADMIN ---
  Future<Movie> createMovie(Map<String, dynamic> data) async {
    final r = await http.post(Uri.parse('$baseUrl/movies'),
        headers: _headers, body: jsonEncode(data));
    if (r.statusCode == 200) return Movie.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
    throw Exception('Gagal: ${r.body}');
  }

  Future<Movie> updateMovie(int id, Map<String, dynamic> data) async {
    final r = await http.put(Uri.parse('$baseUrl/movies/$id'),
        headers: _headers, body: jsonEncode(data));
    if (r.statusCode == 200) return Movie.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
    throw Exception('Gagal update film: ${r.body}');
  }

  Future<void> deleteMovie(int id) async {
    final r = await http.delete(
        Uri.parse('$baseUrl/movies/$id'), headers: _headers);
    if (r.statusCode != 200) throw Exception('Gagal hapus film');
  }

  Future<List<Map<String, dynamic>>> getAdminUsers() async {
    final r = await http.get(
        Uri.parse('$baseUrl/admin/users'), headers: _headers);
    if (r.statusCode == 200) {
      final List<dynamic> data = jsonDecode(r.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Gagal ambil data user admin');
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    await http.put(Uri.parse('$baseUrl/admin/users/$id'),
        headers: _headers, body: jsonEncode(data));
  }

  Future<void> changeUserSubscription(int id, String type) async =>
      http.put(Uri.parse('$baseUrl/admin/users/$id/subscription?type=$type'),
          headers: _headers);

  Future<void> changeUserRole(int id, String role) async =>
      http.put(Uri.parse('$baseUrl/admin/users/$id/role?role=$role'),
          headers: _headers);

  Future<void> deleteUser(int id) async =>
      http.delete(Uri.parse('$baseUrl/admin/users/$id'), headers: _headers);

  Future<Map<String, dynamic>> getDashboardStats() async {
    final r = await http.get(
        Uri.parse('$baseUrl/admin/dashboard'), headers: _headers);
    if (r.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(r.body));
    }
    throw Exception('Gagal ambil stats');
  }

  Future<List<Map<String, dynamic>>> getGenres() async {
    final r = await http.get(Uri.parse('$baseUrl/genres'), headers: _headers);
    if (r.statusCode == 200) {
      final List<dynamic> data = jsonDecode(r.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }
}