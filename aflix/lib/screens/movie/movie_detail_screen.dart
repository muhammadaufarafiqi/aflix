import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/movie.dart';
import '../../providers/auth_provider.dart';
import '../../providers/movie_provider.dart';
import '../../theme/app_theme.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;
  final Movie? movie;
  const MovieDetailScreen({super.key, required this.movieId, this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetailScreen> {
  Movie? _movie;
  bool _loading         = false;
  bool _isFavorited     = false;
  bool _isDownloaded    = false;
  bool _downloadLoading = false;

  @override
  void initState() {
    super.initState();
    _movie = widget.movie;
    if (_movie == null) {
      _fetch();
    } else {
      _trackView();
      _checkStatuses();
    }
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final m = await context.read<AuthProvider>().api
          .getMovieById(widget.movieId);
      setState(() { _movie = m; _loading = false; });
      _trackView();
      _checkStatuses();
    } catch (e) {
      debugPrint('Error fetching movie detail: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _checkStatuses() async {
    if (_movie == null) return;
    final api = context.read<AuthProvider>().api;
    final fav  = await api.checkFavoriteStatus(_movie!.id);
    final down = await api.checkDownloadStatus(_movie!.id);
    if (mounted) setState(() { _isFavorited = fav; _isDownloaded = down; });
  }

  Future<void> _toggleFavorite() async {
    if (_movie == null) return;
    final api = context.read<AuthProvider>().api;
    await api.toggleFavorite(_movie!.id);
    setState(() => _isFavorited = !_isFavorited);
    if (mounted) context.read<MovieProvider>().fetchFavorites(api);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_isFavorited
          ? '❤️ Ditambahkan ke Favorit' : 'Dihapus dari Favorit'),
      backgroundColor:
      _isFavorited ? AppTheme.primary : Colors.grey[800],
      duration: const Duration(seconds: 2),
    ));
  }

  // ✅ Toggle Download
  Future<void> _toggleDownload() async {
    if (_movie == null) return;
    setState(() => _downloadLoading = true);
    final api = context.read<AuthProvider>().api;
    try {
      if (_isDownloaded) {
        await api.removeDownload(_movie!.id);
        setState(() => _isDownloaded = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('🗑️ Dihapus dari Unduhan'),
                backgroundColor: Colors.grey));
      } else {
        await api.addDownload(_movie!.id);
        setState(() => _isDownloaded = true);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('✅ Ditambahkan ke Unduhan'),
                backgroundColor: Colors.green));
      }
      if (mounted) context.read<MovieProvider>().fetchDownloads(api);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'),
              backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _downloadLoading = false);
    }
  }

  Future<void> _trackView() async {
    if (_movie != null) {
      await context.read<AuthProvider>().api.trackView(_movie!.id);
    }
  }

  void _play(String? url) {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Video tidak tersedia'),
          backgroundColor: Colors.red));
      return;
    }
    final user = context.read<AuthProvider>().user;
    if (_movie!.isPremium && user?.isPremium != true) {
      _showPremiumDialog();
      return;
    }
    context.push('/player', extra: {
      'title': _movie!.title,
      'videoUrl': url,
      'movieId': _movie!.id,
    });
  }

  void _showPremiumDialog() {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(children: [
        Icon(Icons.lock_outlined, color: Colors.amber),
        SizedBox(width: 8),
        Text('Konten Premium', style: TextStyle(color: Colors.white)),
      ]),
      content: const Text('Upgrade ke Premium untuk menikmati konten ini.',
          style: TextStyle(color: AppTheme.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Nanti')),
        ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('Upgrade', style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold))),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
            child: CircularProgressIndicator(color: AppTheme.primary)));

    if (_movie == null) return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(backgroundColor: Colors.transparent,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white),
                onPressed: () => context.pop())),
        body: const Center(child: Text('Film tidak ditemukan',
            style: TextStyle(color: Colors.white))));

    final m = _movie!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(slivers: [

        // ── HERO BANNER ──
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: AppTheme.background,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle),
            child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
                onPressed: () => context.pop()),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle),
              child: IconButton(
                  icon: Icon(
                      _isFavorited
                          ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorited
                          ? AppTheme.primary : Colors.white,
                      size: 20),
                  onPressed: _toggleFavorite),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(fit: StackFit.expand, children: [
              (m.bannerUrl != null && m.bannerUrl!.isNotEmpty)
                  ? CachedNetworkImage(
                  imageUrl: m.bannerUrl!, fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: AppTheme.card),
                  errorWidget: (_, __, ___) =>
                      _thumbnailFallback(m.thumbnailUrl))
                  : _thumbnailFallback(m.thumbnailUrl),
              Container(decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        AppTheme.background,
                      ],
                      stops: const [0.4, 0.75, 1.0]))),
              // Play button di tengah
              Center(child: GestureDetector(
                onTap: () => _play(m.fullVideoUrl ?? m.videoUrl),
                child: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white38, width: 1.5)),
                  child: const Icon(Icons.play_arrow,
                      color: Colors.white, size: 32),
                ),
              )),
              if (m.isPremium)
                Positioned(top: 60, left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.amber,
                          borderRadius: BorderRadius.circular(4)),
                      child: const Row(
                          mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.star, color: Colors.black, size: 12),
                        SizedBox(width: 4),
                        Text('PREMIUM', style: TextStyle(
                            color: Colors.black, fontSize: 11,
                            fontWeight: FontWeight.bold)),
                      ]),
                    )),
            ]),
          ),
        ),

        // ── KONTEN ──
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Judul
            Text(m.title, style: const TextStyle(color: Colors.white,
                fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
            const SizedBox(height: 10),

            // Metadata chips
            Wrap(spacing: 12, runSpacing: 6, children: [
              if (m.rating != null)
                _metaBadge(child: Row(
                    mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.star, color: Colors.amber, size: 13),
                  const SizedBox(width: 4),
                  Text(m.rating!.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white,
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ])),
              if (m.releaseYear != null)
                _metaBadge(child: Text('${m.releaseYear}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12))),
              if (m.duration != null)
                _metaBadge(child: Row(
                    mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.access_time,
                      color: AppTheme.textSecondary, size: 12),
                  const SizedBox(width: 4),
                  Text(m.duration!, style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
                ])),
              if (m.contentType != null)
                _metaBadge(child: Text(m.contentType!,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12))),
            ]),
            const SizedBox(height: 20),

            // Tombol Putar & Trailer
            Row(children: [
              Expanded(child: ElevatedButton.icon(
                onPressed: () => _play(m.fullVideoUrl ?? m.videoUrl),
                icon: const Icon(Icons.play_arrow,
                    color: Colors.black, size: 22),
                label: const Text('Putar', style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold,
                    fontSize: 15)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
              )),
              if (m.trailerUrl != null) ...[
                const SizedBox(width: 10),
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => _play(m.trailerUrl),
                  icon: const Icon(Icons.ondemand_video_outlined,
                      color: Colors.white, size: 18),
                  label: const Text('Trailer',
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                )),
              ],
            ]),
            const SizedBox(height: 16),

            // ── Aksi: Favorit | Unduh | Bagikan ──
            Row(children: [
              // Favorit
              Expanded(child: _actionBtn(
                icon: _isFavorited
                    ? Icons.favorite : Icons.favorite_border,
                label: _isFavorited ? 'Difavoritkan' : 'Favorit',
                color: _isFavorited ? AppTheme.primary : Colors.white,
                onTap: _toggleFavorite,
              )),

              // ✅ Unduh
              Expanded(child: _downloadLoading
                  ? Column(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 48, height: 48,
                    decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Center(
                        child: SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(
                                color: AppTheme.primary,
                                strokeWidth: 2)))),
                const SizedBox(height: 6),
                const Text('Memproses...',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11)),
              ])
                  : _actionBtn(
                icon: _isDownloaded
                    ? Icons.download_done : Icons.download_outlined,
                label: _isDownloaded ? 'Diunduh' : 'Unduh',
                color: _isDownloaded ? Colors.green : Colors.white,
                onTap: _toggleDownload,
              )),

              // Bagikan
              Expanded(child: _actionBtn(
                icon: Icons.share_outlined,
                label: 'Bagikan',
                color: Colors.white,
                onTap: () {},
              )),
            ]),

            const SizedBox(height: 24),
            const Divider(color: AppTheme.card),
            const SizedBox(height: 16),

            // Sinopsis
            if (m.description != null && m.description!.isNotEmpty) ...[
              const Text('Sinopsis', style: TextStyle(color: Colors.white,
                  fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _ExpandableText(text: m.description!),
              const SizedBox(height: 20),
            ],

            // Genre chips
            if (m.genres != null && m.genres!.isNotEmpty) ...[
              const Text('Genre', style: TextStyle(color: Colors.white,
                  fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8,
                  children: m.genres!.map((g) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.1))),
                    child: Text(g.name, style: const TextStyle(
                        color: Colors.white, fontSize: 12)),
                  )).toList()),
              const SizedBox(height: 20),
            ],

            // Detail info
            const Text('Detail', style: TextStyle(color: Colors.white,
                fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                if (m.releaseYear != null)
                  _detailRow('Tahun Rilis', '${m.releaseYear}'),
                if (m.duration != null)
                  _detailRow('Durasi', m.duration!),
                if (m.contentType != null)
                  _detailRow('Tipe', m.contentType!),
                if (m.ageRating != null)
                  _detailRow('Rating Usia', m.ageRating!),
                _detailRow('Akses', m.isPremium ? 'Premium' : 'Gratis'),
              ]),
            ),
          ]),
        )),
      ]),
    );
  }

  Widget _thumbnailFallback(String? thumbUrl) {
    if (thumbUrl != null && thumbUrl.isNotEmpty) {
      return CachedNetworkImage(imageUrl: thumbUrl, fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: AppTheme.card),
          errorWidget: (_, __, ___) => Container(color: AppTheme.card,
              child: const Icon(Icons.movie,
                  color: Colors.white12, size: 60)));
    }
    return Container(color: AppTheme.card,
        child: const Icon(Icons.movie, color: Colors.white12, size: 60));
  }

  Widget _metaBadge({required Widget child}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: AppTheme.card,
        borderRadius: BorderRadius.circular(6)),
    child: child,
  );

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 48, height: 48,
              decoration: BoxDecoration(color: AppTheme.card,
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22)),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ]),
      );

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Text(label, style: const TextStyle(
          color: AppTheme.textSecondary, fontSize: 13)),
      const Spacer(),
      Text(value, style: const TextStyle(color: Colors.white,
          fontSize: 13, fontWeight: FontWeight.w500)),
    ]),
  );
}

// ── Expandable Text ──────────────────────────────────────────
class _ExpandableText extends StatefulWidget {
  final String text;
  const _ExpandableText({required this.text});
  @override State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    AnimatedCrossFade(
      duration: const Duration(milliseconds: 250),
      crossFadeState: _expanded
          ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: Text(widget.text, maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppTheme.textSecondary,
              fontSize: 14, height: 1.6)),
      secondChild: Text(widget.text,
          style: const TextStyle(color: AppTheme.textSecondary,
              fontSize: 14, height: 1.6)),
    ),
    const SizedBox(height: 6),
    GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Text(_expanded ? 'Lebih sedikit ▲' : 'Selengkapnya ▼',
          style: const TextStyle(color: AppTheme.primary,
              fontSize: 13, fontWeight: FontWeight.w600)),
    ),
  ],
  );
}