import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chewie/chewie.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart'; // Import ApiService

class VideoPlayerScreen extends StatefulWidget {
  final String? title, videoUrl;
  final int? movieId;

  const VideoPlayerScreen({super.key, this.title, this.videoUrl, this.movieId});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayerScreen> {
  VideoPlayerController? _vCtrl;
  ChewieController?      _cCtrl;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    // Mengatur orientasi layar ke landscape saat menonton
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);

    // Step Tambahan: Track View (Menghitung jumlah tontonan di backend)
    if (widget.movieId != null) {
      context.read<AuthProvider>().api.trackView(widget.movieId!);
    }

    _init();
  }

  Future<void> _init() async {
    if (widget.videoUrl == null || widget.videoUrl!.isEmpty) {
      setState(() => _error = true);
      return;
    }
    try {
      _vCtrl = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
      await _vCtrl!.initialize();

      _cCtrl = ChewieController(
        videoPlayerController: _vCtrl!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppTheme.primary,
          handleColor: AppTheme.primary,
          bufferedColor: Colors.white24,
          backgroundColor: Colors.white12,
        ),
      );

      _vCtrl!.addListener(_progressListener);
      setState(() {});
    } catch (e) {
      debugPrint("Video Init Error: $e");
      setState(() => _error = true);
    }
  }

  // Listener untuk menyimpan progress ke Spring Boot
  void _progressListener() {
    final pos = _vCtrl?.value.position.inSeconds ?? 0;
    // Simpan otomatis setiap 30 detik agar jika aplikasi crash, progress tetap aman
    if (pos > 0 && pos % 30 == 0 && widget.movieId != null) {
      context.read<AuthProvider>().api.saveProgress(widget.movieId!, pos);
    }
  }

  @override
  void dispose() {
    // Kembalikan orientasi layar ke portrait saat keluar dari player
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Simpan progress terakhir satu kali lagi sebelum controller dihapus
    if (_vCtrl != null && widget.movieId != null) {
      final finalPos = _vCtrl!.value.position.inSeconds;
      context.read<AuthProvider>().api.saveProgress(widget.movieId!, finalPos);
    }

    _vCtrl?.removeListener(_progressListener);
    _cCtrl?.dispose();
    _vCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => context.pop(),
      ),
      title: Text(
        widget.title ?? '',
        style: const TextStyle(color: Colors.white, fontSize: 15),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    body: _error
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 52),
          const SizedBox(height: 12),
          const Text('Gagal memuat video', style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Pastikan URL video valid & server aktif', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() => _error = false);
              _init();
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    )
        : _cCtrl == null
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
        : Center(
      child: AspectRatio(
        aspectRatio: _vCtrl?.value.aspectRatio ?? 16/9,
        child: Chewie(controller: _cCtrl!),
      ),
    ),
  );
}