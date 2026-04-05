import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:chewie/chewie.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

// Import youtube_player_flutter hanya untuk Android/iOS
import 'youtube_player_wrapper.dart';

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
  bool _isYoutube = false;
  String? _youtubeId;
  bool _error   = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
      ]);
    }
    if (widget.movieId != null) {
      context.read<AuthProvider>().api.trackView(widget.movieId!);
    }
    _init();
  }

  Future<void> _init() async {
    final url = widget.videoUrl ?? '';
    if (url.isEmpty) {
      setState(() { _error = true; _loading = false; });
      return;
    }

    // ── Deteksi YouTube ──
    final ytId = _extractYoutubeId(url);
    if (ytId != null) {
      _isYoutube = true;
      _youtubeId = ytId;

      if (kIsWeb) {
        // Chrome: buka YouTube di tab baru
        setState(() => _loading = false);
        await _launchYoutube(url);
      } else {
        // Android: pakai youtube_player_flutter
        setState(() => _loading = false);
      }
      return;
    }

    // ── MP4 player ──
    try {
      _vCtrl = VideoPlayerController.networkUrl(Uri.parse(url));
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
      setState(() => _loading = false);
    } catch (e) {
      debugPrint('Video Init Error: $e');
      setState(() { _error = true; _loading = false; });
    }
  }

  // ── Extract YouTube ID dari berbagai format URL ──
  String? _extractYoutubeId(String url) {
    final regExp = RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]{11})',
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  Future<void> _launchYoutube(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _progressListener() {
    final pos = _vCtrl?.value.position.inSeconds ?? 0;
    if (pos > 0 && pos % 30 == 0 && widget.movieId != null) {
      context.read<AuthProvider>().api.saveProgress(widget.movieId!, pos);
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
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
  Widget build(BuildContext context) {
    // ── Android + YouTube ──
    if (_isYoutube && !kIsWeb && _youtubeId != null) {
      return YoutubePlayerWrapper(
        videoId: _youtubeId!,
        title: widget.title ?? '',
        onBack: () => context.pop(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.title ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 15),
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _error
          ? _buildError()
      // ── Chrome + YouTube: tampilkan tombol buka di YouTube ──
          : (_isYoutube && kIsWeb)
          ? _buildWebYoutube()
          : _cCtrl == null
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Center(
        child: AspectRatio(
          aspectRatio: _vCtrl?.value.aspectRatio ?? 16 / 9,
          child: Chewie(controller: _cCtrl!),
        ),
      ),
    );
  }

  // ── UI untuk Chrome: tampilkan thumbnail + tombol buka YouTube ──
  Widget _buildWebYoutube() {
    final thumbUrl = 'https://img.youtube.com/vi/$_youtubeId/maxresdefault.jpg';
    final ytUrl    = 'https://www.youtube.com/watch?v=$_youtubeId';
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center, children: [
      // Thumbnail YouTube
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(thumbUrl,
            width: 480, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
                width: 480, height: 270, color: AppTheme.card,
                child: const Icon(Icons.movie, color: Colors.white24, size: 60))),
      ),
      const SizedBox(height: 24),
      Text(widget.title ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 18,
              fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Video tersedia di YouTube',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: () => _launchYoutube(ytUrl),
        icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 22),
        label: const Text('Tonton di YouTube',
            style: TextStyle(color: Colors.white, fontSize: 15,
                fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF0000),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      ),
    ],
    ));
  }

  Widget _buildError() => Center(child: Column(
    mainAxisAlignment: MainAxisAlignment.center, children: [
    const Icon(Icons.error_outline, color: Colors.red, size: 52),
    const SizedBox(height: 12),
    const Text('Gagal memuat video',
        style: TextStyle(color: Colors.white, fontSize: 16)),
    const SizedBox(height: 8),
    const Text('Pastikan URL video valid & server aktif',
        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
    const SizedBox(height: 20),
    ElevatedButton(
        onPressed: () { setState(() { _error = false; _loading = true; }); _init(); },
        child: const Text('Coba Lagi')),
  ],
  ));
}