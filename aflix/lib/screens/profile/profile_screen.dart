import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _nameController = TextEditingController(); // Untuk input nama
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Mengambil data profil dari backend
  Future<void> _fetchProfile() async {
    try {
      final data = await _apiService.getMyProfile();
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat profil: $e")),
        );
      }
    }
  }

  // Fungsi untuk menampilkan dialog Edit Profil (Update Name)
  void _showEditDialog() {
    _nameController.text = _userData?['name'] ?? "";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Edit Profil", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Nama Lengkap",
            labelStyle: TextStyle(color: Colors.red),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              // Memanggil fungsi update dari ApiService
              final success = await _apiService.updateMyProfile(
                name: _nameController.text,
                email: _userData?['email'] ?? "",
              );

              if (success) {
                if (mounted) Navigator.pop(context);
                _fetchProfile(); // Refresh tampilan agar nama berubah
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profil berhasil diperbarui!")),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Profil Saya", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.red,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // Info User
            Text(
              _userData?['name'] ?? "No Name",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              _userData?['email'] ?? "",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const SizedBox(height: 30),
            const Divider(color: Colors.white24),

            // Detail Akun
            _buildInfoTile("Status Langganan",
                _userData?['subscriptionType'] ?? "FREE"),
            _buildInfoTile("Role Akun", _userData?['role'] ?? "USER"),

            const SizedBox(height: 40),

            // Tombol Edit Profil
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showEditDialog, // Menjalankan dialog edit
                style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Edit Profil"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title,
          style: const TextStyle(color: Colors.grey, fontSize: 14)),
      subtitle: Text(value,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}