import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _loading = false;
  bool _initialized = false;
  String? _error;

  final ApiService _api = ApiService();

  // ════════════════════════════════════════════════
  // GETTERS
  // ════════════════════════════════════════════════
  UserModel? get user => _user;
  String? get token => _user?.token;
  bool get isLoading => _loading;
  bool get isLoggedIn => _user != null && _user?.token != null; // Cek token juga
  bool get isInitialized => _initialized;
  String? get error => _error;
  ApiService get api => _api;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    await _restore();
  }

  // Fungsi untuk mengambil data user yang tersimpan saat aplikasi baru dibuka
  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('user');

      if (data != null) {
        final decodedData = jsonDecode(data);
        _user = UserModel.fromJson(decodedData);
        _api.setToken(_user?.token);
        debugPrint("✅ Auth: User restored dari storage: ${_user?.email}");
      }
    } catch (e) {
      debugPrint("❌ Auth Restore Error: $e");
      _error = "Failed to load user session";
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Panggil API Login
      final result = await _api.login(email, password);

      // 2. Simpan ke variabel lokal (State)
      _user = result;

      // 3. Pasang token ke header API Service
      _api.setToken(_user?.token);

      // 4. WAJIB: Simpan ke SharedPreferences dan tunggu sampai selesai (await)
      await _persist();

      debugPrint("✅ Auth: Login Berhasil. Token: ${_user?.token}");

      _loading = false;
      notifyListeners(); // Beritahu UI untuk pindah halaman
      return true;
    } catch (e) {
      debugPrint("❌ Auth Login Error: $e");
      _error = e.toString().replaceAll('Exception: ', '');
      _loading = false;
      _user = null; // Pastikan user null jika gagal
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.register(name, email, password);
      _user = result;
      _api.setToken(_user?.token);
      await _persist();

      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _api.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    debugPrint("✅ Auth: User logged out");
    notifyListeners();
  }

  // Fungsi internal untuk menyimpan data ke memori permanen
  Future<void> _persist() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String userJson = jsonEncode(_user!.toJson());
    await prefs.setString('user', userJson);
    debugPrint("✅ Auth: Data user tersimpan di SharedPreferences");
  }
}