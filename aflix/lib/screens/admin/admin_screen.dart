import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/movie.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override State<AdminScreen> createState() => _AdminState();
}

class _AdminState extends State<AdminScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(
      backgroundColor: const Color(0xFF0A0A0A),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => context.pop(),
      ),
      title: Row(children: [
        Container(width: 8, height: 8,
            decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        const Text('Admin Panel',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ]),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: const Color(0xFF0A0A0A),
          child: Row(children: [
            _tabBtn('Dashboard', 0, Icons.dashboard_outlined),
            _tabBtn('Film',      1, Icons.movie_outlined),
            _tabBtn('Users',     2, Icons.people_outlined),
          ]),
        ),
      ),
    ),
    body: IndexedStack(
      index: _tab,
      children: const [_DashboardTab(), _MoviesTab(), _UsersTab()],
    ),
  );

  Widget _tabBtn(String label, int i, IconData icon) {
    final active = _tab == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = i),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(
              color: active ? AppTheme.primary : Colors.transparent,
              width: 2,
            )),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 16, color: active ? AppTheme.primary : AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(
              color: active ? AppTheme.primary : AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            )),
          ]),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// DASHBOARD TAB
// ════════════════════════════════════════════════════════════
class _DashboardTab extends StatefulWidget {
  const _DashboardTab();
  @override State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  Map<String, dynamic>? stats;
  bool loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final api  = context.read<AuthProvider>().api;
      final data = await api.getDashboardStats();
      setState(() { stats = data; loading = false; });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    if (stats == null) return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: AppTheme.textSecondary, size: 48),
        const SizedBox(height: 12),
        const Text('Gagal memuat data', style: TextStyle(color: Colors.white)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () { setState(() => loading = true); _load(); },
          child: const Text('Coba Lagi'),
        ),
      ],
    ));

    final cards = [
      ('Total Users',   '${stats!['totalUsers']   ?? 0}', Icons.people,                 Colors.blue),
      ('Total Film',    '${stats!['totalMovies']  ?? 0}', Icons.movie,                  AppTheme.primary),
      ('Premium Users', '${stats!['premiumUsers'] ?? 0}', Icons.star,                   Colors.amber),
      ('Total Views',   _fmt(stats!['totalViews'] ?? 0),  Icons.remove_red_eye_outlined, Colors.green),
      ('Film Gratis',   '${stats!['freeMovies']   ?? 0}', Icons.lock_open_outlined,     Colors.teal),
      ('Film Premium',  '${stats!['premiumMovies']?? 0}', Icons.lock_outlined,          Colors.orange),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Overview',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 1.5,
            crossAxisSpacing: 12, mainAxisSpacing: 12,
          ),
          itemCount: cards.length,
          itemBuilder: (_, i) => _StatCard(
            label: cards[i].$1, value: cards[i].$2,
            icon:  cards[i].$3, color: cards[i].$4,
          ),
        ),
        const SizedBox(height: 24),
        const Text('Akun Tersedia',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
          child: Column(children: [
            _accountRow('admin@aflix.com', 'admin123', 'ADMIN',   Colors.red),
            const Divider(color: AppTheme.card, height: 20),
            _accountRow('demo@aflix.com',  'demo123',  'FREE',    Colors.blue),
            const Divider(color: AppTheme.card, height: 20),
            _accountRow('user@aflix.com',  'user123',  'PREMIUM', Colors.amber),
          ]),
        ),
      ]),
    );
  }

  Widget _accountRow(String email, String pass, String badge, Color color) =>
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(email, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          Text(pass,  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
              color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
          child: Text(badge, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ]);

  String _fmt(dynamic v) {
    final n = int.tryParse(v.toString()) ?? 0;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000)    return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
            color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 20),
      ),
      const Spacer(),
      Text(value,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
    ]),
  );
}

// ════════════════════════════════════════════════════════════
// MOVIES TAB — CRUD
// ════════════════════════════════════════════════════════════
class _MoviesTab extends StatefulWidget {
  const _MoviesTab();
  @override State<_MoviesTab> createState() => _MoviesTabState();
}

class _MoviesTabState extends State<_MoviesTab> {
  List<Movie> _movies = [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final movies = await context.read<AuthProvider>().api.getAllMovies();
      setState(() { _movies = movies; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    floatingActionButton: FloatingActionButton.extended(
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      onPressed: () => _showMovieDialog(context),
      icon: const Icon(Icons.add),
      label: const Text('Tambah Film'),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
        : RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.primary,
      child: _movies.isEmpty
          ? const Center(child: Text('Belum ada film',
          style: TextStyle(color: AppTheme.textSecondary)))
          : ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _movies.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.card),
        itemBuilder: (_, i) {
          final m = _movies[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 6),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(width: 64, height: 44,
                child: m.thumbnailUrl != null && m.thumbnailUrl!.isNotEmpty
                    ? Image.network(m.thumbnailUrl!, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: AppTheme.card,
                            child: const Icon(Icons.broken_image,
                                color: Colors.white24, size: 20)))
                    : Container(color: AppTheme.card,
                    child: const Icon(Icons.movie,
                        color: Colors.white24, size: 20)),
              ),
            ),
            title: Text(m.title,
                style: const TextStyle(color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.w500),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(
                '${m.contentType ?? '-'} • ${m.contentAccess ?? '-'} • ⭐${m.rating ?? '-'}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              if (m.isFeatured)
                const Icon(Icons.star, color: Colors.amber, size: 14),
              if (m.isTrending)
                const Icon(Icons.local_fire_department,
                    color: Colors.orange, size: 14),
              PopupMenuButton<String>(
                color: AppTheme.surface,
                icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
                onSelected: (v) {
                  if (v == 'edit')   _showMovieDialog(context, movie: m);
                  if (v == 'delete') _confirmDelete(context, m);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined, size: 16, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Edit', style: TextStyle(color: Colors.white)),
                      ])),
                  const PopupMenuItem(value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ])),
                ],
              ),
            ]),
          );
        },
      ),
    ),
  );

  void _confirmDelete(BuildContext ctx, Movie m) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Hapus Film', style: TextStyle(color: Colors.white)),
      content: Text('Yakin hapus "${m.title}"?',
          style: const TextStyle(color: AppTheme.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(ctx);
            try {
              await context.read<AuthProvider>().api.deleteMovie(m.id);
              _load();
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Film dihapus'),
                      backgroundColor: Colors.green));
            } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal: $e'),
                      backgroundColor: Colors.red));
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Hapus', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  // ── DIALOG TAMBAH / EDIT FILM ──────────────────────────────
  void _showMovieDialog(BuildContext ctx, {Movie? movie}) {
    final isEdit  = movie != null;
    final title   = TextEditingController(text: movie?.title          ?? '');
    final desc    = TextEditingController(text: movie?.description    ?? '');
    final thumb   = TextEditingController(text: movie?.thumbnailUrl   ?? '');
    final banner  = TextEditingController(text: movie?.bannerUrl      ?? '');
    final trailer = TextEditingController(text: movie?.trailerUrl     ?? '');
    final video   = TextEditingController(text: movie?.fullVideoUrl   ?? '');
    final year    = TextEditingController(text: movie?.releaseYear?.toString() ?? '');
    final dur     = TextEditingController(text: movie?.duration       ?? '');
    final rating  = TextEditingController(text: movie?.rating?.toString()      ?? '');
    final age     = TextEditingController(text: movie?.ageRating      ?? '');

    String cType   = movie?.contentType   ?? 'MOVIE';
    String cAccess = movie?.contentAccess ?? 'FREE';
    bool featured  = movie?.isFeatured    ?? false;
    bool trending  = movie?.isTrending    ?? false;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => StatefulBuilder(builder: (_, setS) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16, right: 16, top: 16),
        child: SingleChildScrollView(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(children: [
              Text(isEdit ? 'Edit Film' : 'Tambah Film',
                  style: const TextStyle(color: Colors.white, fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                  onPressed: () => Navigator.pop(ctx)),
            ]),
            const SizedBox(height: 16),

            // ── Judul ──
            _field(title, 'Judul Film *'),
            const SizedBox(height: 10),

            // ── Deskripsi ──
            _field(desc, 'Deskripsi', maxLines: 3),
            const SizedBox(height: 10),

            // ── Thumbnail URL + preview ──
            _sectionLabel('🖼️ Thumbnail URL (poster card)'),
            const SizedBox(height: 4),
            TextField(
              controller: thumb,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              onChanged: (_) => setS(() {}),
              decoration: _inputDeco('https://image.tmdb.org/t/p/w500/...'),
            ),
            if (thumb.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(thumb.text,
                    height: 160, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _urlError('Thumbnail tidak valid')),
              ),
            ],
            const SizedBox(height: 10),

            // ── Banner URL + preview ──
            _sectionLabel('🎞️ Banner URL (hero halaman detail)'),
            const SizedBox(height: 4),
            TextField(
              controller: banner,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              onChanged: (_) => setS(() {}),
              decoration: _inputDeco('https://image.tmdb.org/t/p/original/...'),
            ),
            if (banner.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(banner.text,
                    height: 120, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _urlError('Banner tidak valid')),
              ),
            ],
            const SizedBox(height: 10),

            // ── Trailer & Video URL ──
            _sectionLabel('🎬 URL Video'),
            const SizedBox(height: 4),
            _field(trailer, 'Trailer URL (MP4)'),
            const SizedBox(height: 8),
            _field(video,   'Full Video URL (MP4) *'),
            const SizedBox(height: 10),

            // ── Metadata row ──
            _sectionLabel('📋 Informasi Film'),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(child: _field(year,   'Tahun',   type: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(child: _field(dur,    'Durasi')),
              const SizedBox(width: 8),
              Expanded(child: _field(rating, 'Rating',  type: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(child: _field(age,    'Usia')),
            ]),
            const SizedBox(height: 10),

            // ── Tipe & Akses ──
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Tipe Konten'),
                const SizedBox(height: 4),
                _dropDown(['MOVIE', 'SERIES', 'DOCUMENTARY', 'ANIME'], cType,
                        (v) => setS(() => cType = v!)),
              ])),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionLabel('Akses'),
                const SizedBox(height: 4),
                _dropDown(['FREE', 'PREMIUM'], cAccess,
                        (v) => setS(() => cAccess = v!)),
              ])),
            ]),
            const SizedBox(height: 10),

            // ── Featured & Trending toggle ──
            Row(children: [
              Expanded(child: CheckboxListTile(
                  value: featured, onChanged: (v) => setS(() => featured = v!),
                  title: const Text('⭐ Featured',
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                  activeColor: AppTheme.primary,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading)),
              Expanded(child: CheckboxListTile(
                  value: trending, onChanged: (v) => setS(() => trending = v!),
                  title: const Text('🔥 Trending',
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                  activeColor: AppTheme.primary,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading)),
            ]),
            const SizedBox(height: 16),

            // ── Submit button ──
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () async {
                  if (title.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Judul tidak boleh kosong!'),
                            backgroundColor: Colors.orange));
                    return;
                  }
                  // ✅ Semua key pakai snake_case agar sesuai backend Spring Boot
                  final data = {
                    'title':          title.text.trim(),
                    'description':    desc.text,
                    'thumbnail_url':  thumb.text,
                    'banner_url':     banner.text,
                    'trailer_url':    trailer.text,
                    'full_video_url': video.text,
                    'release_year':   int.tryParse(year.text),
                    'duration':       dur.text,
                    'rating':         double.tryParse(rating.text),
                    'age_rating':     age.text,
                    'contentType':    cType,
                    'contentAccess':  cAccess,
                    'isFeatured':     featured,
                    'isTrending':     trending,
                  };
                  try {
                    final api = context.read<AuthProvider>().api;
                    if (isEdit) await api.updateMovie(movie.id, data);
                    else        await api.createMovie(data);
                    if (mounted) { Navigator.pop(ctx); _load(); }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(isEdit ? '✅ Film diperbarui!' : '✅ Film ditambahkan!'),
                        backgroundColor: Colors.green));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal: $e'),
                            backgroundColor: Colors.red));
                  }
                },
                child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Film',
                    style: const TextStyle(color: Colors.white,
                        fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        )),
      )),
    );
  }

  // ── Helpers ───────────────────────────────────────────────
  Widget _sectionLabel(String text) =>
      Text(text, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12,
          fontWeight: FontWeight.w500));

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF444444), fontSize: 12),
    filled: true,
    fillColor: AppTheme.card,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.primary)),
  );

  Widget _urlError(String msg) => Container(
    height: 40, color: Colors.red.withOpacity(0.1),
    child: Center(child: Text(msg,
        style: const TextStyle(color: Colors.red, fontSize: 12))),
  );

  Widget _field(TextEditingController c, String hint,
      {TextInputType? type, int maxLines = 1}) =>
      TextField(
        controller: c, keyboardType: type, maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          filled: true, fillColor: AppTheme.card,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primary)),
        ),
      );

  Widget _dropDown(List<String> items, String val, void Function(String?) onChanged) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10), height: 44,
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(8)),
        child: DropdownButton<String>(
          value: val,
          items: items.map((e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: const TextStyle(color: Colors.white, fontSize: 13)))).toList(),
          onChanged: onChanged,
          isExpanded: true, underline: const SizedBox(), dropdownColor: AppTheme.card,
        ),
      );
}

// ════════════════════════════════════════════════════════════
// USERS TAB — CRUD
// ════════════════════════════════════════════════════════════
class _UsersTab extends StatefulWidget {
  const _UsersTab();
  @override State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final users = await context.read<AuthProvider>().api.getAdminUsers();
      setState(() { _users = users; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => _loading
      ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
      : RefreshIndicator(
    onRefresh: _load,
    color: AppTheme.primary,
    child: ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.card),
      itemBuilder: (_, i) {
        final u       = _users[i];
        final role    = u['role']             ?? 'USER';
        final sub     = u['subscriptionType'] ?? 'FREE';
        final isAdmin = role == 'ADMIN';
        final isPrem  = sub  == 'PREMIUM';
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
          leading: CircleAvatar(
            backgroundColor: isAdmin ? AppTheme.primary : AppTheme.card,
            child: Text(
                (u['name'] as String? ?? 'U').substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          title: Text(u['name'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 13,
                  fontWeight: FontWeight.w500)),
          subtitle: Text(u['email'] ?? '',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            _badge(role, isAdmin ? Colors.red  : Colors.blue),
            const SizedBox(width: 4),
            _badge(sub,  isPrem  ? Colors.amber : Colors.grey),
            PopupMenuButton<String>(
              color: AppTheme.surface,
              icon: const Icon(Icons.more_vert,
                  color: AppTheme.textSecondary, size: 18),
              onSelected: (v) {
                if (v == 'makePremium') _changeSub(u['id'],  'PREMIUM');
                if (v == 'makeFree')    _changeSub(u['id'],  'FREE');
                if (v == 'makeAdmin')   _changeRole(u['id'], 'ADMIN');
                if (v == 'makeUser')    _changeRole(u['id'], 'USER');
                if (v == 'delete')      _confirmDelete(u);
              },
              itemBuilder: (_) => [
                if (sub  != 'PREMIUM') _popItem('makePremium', 'Jadikan Premium', Icons.star,                   Colors.amber),
                if (sub  != 'FREE')    _popItem('makeFree',    'Jadikan Free',    Icons.star_border,            Colors.grey),
                if (role != 'ADMIN')   _popItem('makeAdmin',   'Jadikan Admin',   Icons.admin_panel_settings,   Colors.red),
                if (role != 'USER')    _popItem('makeUser',    'Jadikan User',    Icons.person_outline,         Colors.blue),
                _popItem('delete', 'Hapus User', Icons.delete_outline, Colors.red),
              ],
            ),
          ]),
        );
      },
    ),
  );

  PopupMenuItem<String> _popItem(String val, String label, IconData icon, Color color) =>
      PopupMenuItem(value: val, child: Row(children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color, fontSize: 13)),
      ]));

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
        color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
    child: Text(label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
  );

  Future<void> _changeSub(int? id, String type) async {
    if (id == null) return;
    try {
      await context.read<AuthProvider>().api.changeUserSubscription(id, type);
      _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscription diubah ke $type'),
              backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _changeRole(int? id, String role) async {
    if (id == null) return;
    try {
      await context.read<AuthProvider>().api.changeUserRole(id, role);
      _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Role diubah ke $role'),
              backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red));
    }
  }

  void _confirmDelete(Map<String, dynamic> u) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Hapus User', style: TextStyle(color: Colors.white)),
      content: Text('Hapus user "${u['name']}"?',
          style: const TextStyle(color: AppTheme.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Batal')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            try {
              await context.read<AuthProvider>().api.deleteUser(u['id']);
              _load();
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User dihapus'),
                      backgroundColor: Colors.green));
            } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal: $e'),
                      backgroundColor: Colors.red));
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Hapus', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }
}