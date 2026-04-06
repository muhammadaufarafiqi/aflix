import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

class MovieProvider with ChangeNotifier {
  List<Movie> featured      = [];
  List<Movie> trending      = [];
  List<Movie> newReleases   = [];
  List<Movie> all           = [];
  List<Movie> searchResults = [];
  List<Movie> favorites     = [];
  List<Movie> downloads     = []; // ✅

  bool isLoading = false;
  bool hasLoaded = false;
  String? error;

  Future<void> load(ApiService api) async {
    if (hasLoaded) return;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        api.getFeatured(),
        api.getTrending(),
        api.getNewReleases(),
        api.getAllMovies(),
        api.getFavorites(),
        api.getDownloads(), // ✅
      ]);

      featured    = results[0];
      trending    = results[1];
      newReleases = results[2];
      all         = results[3];
      favorites   = results[4];
      downloads   = results[5]; // ✅

      hasLoaded = true;
    } catch (e) {
      error = 'Koneksi ke server gagal. Pastikan Spring Boot aktif.';
      debugPrint('MovieProvider Error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(ApiService api) async {
    hasLoaded = false;
    await load(api);
  }

  Future<void> fetchFavorites(ApiService api) async {
    try {
      favorites = await api.getFavorites();
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch Favorites Error: $e');
    }
  }

  // ✅ Fetch ulang daftar unduhan
  Future<void> fetchDownloads(ApiService api) async {
    try {
      downloads = await api.getDownloads();
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch Downloads Error: $e');
    }
  }

  // ✅ Cek apakah film sudah diunduh
  bool isDownloaded(int movieId) => downloads.any((m) => m.id == movieId);

  Future<void> search(ApiService api, String q) async {
    if (q.isEmpty) {
      searchResults = [];
      notifyListeners();
      return;
    }
    try {
      searchResults = await api.search(q);
      notifyListeners();
    } catch (e) {
      debugPrint('Search Error: $e');
      searchResults = [];
      notifyListeners();
    }
  }
}