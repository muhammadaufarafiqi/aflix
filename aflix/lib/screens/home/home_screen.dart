import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/movie_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/movie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final api = context.read<AuthProvider>().api;
      context.read<MovieProvider>().load(api);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBody: true,
      body: IndexedStack(index: _tab, children: const [
        _HomeTab(),
        _SearchTab(),
        _FavoritesTab(),
        _DownloadsTab(),
        _ProfileTab(),
      ]),
      bottomNavigationBar: _BottomNav(current: _tab, onTap: (i) => setState(() => _tab = i)),
    );
  }
}

// ── BOTTOM NAV ──────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int current;
  final void Function(int) onTap;
  const _BottomNav({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const tabs = [
      ('Home',    Icons.home_outlined,     Icons.home),
      ('Cari',    Icons.search_outlined,   Icons.search),
      ('Favorit', Icons.favorite_outline,  Icons.favorite),
      ('Unduh',   Icons.download_outlined, Icons.download),
      ('Profil',  Icons.person_outline,    Icons.person),
    ];
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5)),
      ),
      child: SafeArea(top: false, child: SizedBox(
        height: 60,
        child: Row(children: List.generate(tabs.length, (i) {
          final active = current == i;
          return Expanded(child: GestureDetector(
            onTap: () => onTap(i), behavior: HitTestBehavior.opaque,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(active ? tabs[i].$3 : tabs[i].$2,
                  color: active ? AppTheme.primary : const Color(0xFF555555), size: 24),
              const SizedBox(height: 3),
              Text(tabs[i].$1, style: TextStyle(
                  color: active ? AppTheme.primary : const Color(0xFF555555),
                  fontSize: 10, fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
            ]),
          ));
        })),
      )),
    );
  }
}

// ── HOME TAB ────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();
  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(builder: (_, movies, __) {
      return CustomScrollView(slivers: [
        SliverAppBar(floating: true, backgroundColor: Colors.transparent,
          title: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(4)),
              child: const Text('AFLIX', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 3)),
            ),
          ]),
          actions: [
            IconButton(icon: const Icon(Icons.notifications_none_outlined, color: Colors.white, size: 26), onPressed: () {}),
            Consumer<AuthProvider>(builder: (ctx, auth, __) {
              if (auth.user?.isAdmin != true) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.admin_panel_settings, color: AppTheme.primary, size: 26),
                onPressed: () => ctx.push('/admin'),
                tooltip: 'Admin Panel',
              );
            }),
          ],
        ),
        if (movies.isLoading)
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppTheme.primary)))
        else if (movies.error != null)
          SliverFillRemaining(child: _ErrorView(onRetry: () {
            final api = context.read<AuthProvider>().api;
            context.read<MovieProvider>().refresh(api);
          }))
        else ...[
            if (movies.featured.isNotEmpty)
              SliverToBoxAdapter(child: _FeaturedBanner(movies: movies.featured)),
            SliverToBoxAdapter(child: _GenreChips()),
            if (movies.trending.isNotEmpty)
              SliverToBoxAdapter(child: _MovieRow(title: '🔥 Trending', movies: movies.trending)),
            if (movies.newReleases.isNotEmpty)
              SliverToBoxAdapter(child: _MovieRow(title: '✨ Baru Rilis', movies: movies.newReleases)),
            if (movies.all.isNotEmpty)
              SliverToBoxAdapter(child: _MovieRow(title: '🎬 Semua Film', movies: movies.all)),
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
      ]);
    });
  }
}

// ── FEATURED BANNER ─────────────────────────────────────────
class _FeaturedBanner extends StatefulWidget {
  final List<Movie> movies;
  const _FeaturedBanner({required this.movies});
  @override State<_FeaturedBanner> createState() => _FeaturedBannerState();
}
class _FeaturedBannerState extends State<_FeaturedBanner> {
  int _current = 0;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CarouselSlider.builder(
        itemCount: widget.movies.length,
        options: CarouselOptions(
          height: 220, viewportFraction: 1.0, autoPlay: true,
          autoPlayInterval: const Duration(seconds: 5),
          onPageChanged: (i, _) => setState(() => _current = i),
        ),
        itemBuilder: (_, i, __) {
          final m = widget.movies[i];
          return GestureDetector(
            onTap: () => context.push('/home/movie/${m.id}', extra: m),
            child: Stack(fit: StackFit.expand, children: [
              (m.bannerUrl != null && m.bannerUrl!.isNotEmpty)
                  ? CachedNetworkImage(imageUrl: m.bannerUrl!, fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppTheme.card),
                  errorWidget: (_, __, ___) => Container(color: AppTheme.card))
                  : Container(color: AppTheme.card),
              Container(decoration: BoxDecoration(gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.85)]))),
              Positioned(bottom: 16, left: 16, right: 16, child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.title, style: const TextStyle(color: Colors.white, fontSize: 20,
                    fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(children: [
                  ElevatedButton.icon(
                    onPressed: () => context.push('/player', extra: {
                      'title': m.title, 'videoUrl': m.fullVideoUrl ?? m.trailerUrl, 'movieId': m.id}),
                    icon: const Icon(Icons.play_arrow, size: 18, color: Colors.black),
                    label: const Text('Putar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/home/movie/${m.id}', extra: m),
                    icon: const Icon(Icons.info_outline, size: 16, color: Colors.white),
                    label: const Text('Info', style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                  ),
                ]),
              ],
              )),
            ]),
          );
        },
      ),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.movies.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: _current == i ? 20 : 6, height: 4,
            decoration: BoxDecoration(
                color: _current == i ? AppTheme.primary : AppTheme.textSecondary,
                borderRadius: BorderRadius.circular(2)),
          ))),
    ]);
  }
}

// ── GENRE CHIPS ─────────────────────────────────────────────
class _GenreChips extends StatefulWidget {
  const _GenreChips();
  @override State<_GenreChips> createState() => _GenreChipsState();
}
class _GenreChipsState extends State<_GenreChips> {
  int _sel = 0;
  final _genres = ['Semua', 'Film', 'Serial', 'Dokumenter', 'Anime'];
  @override
  Widget build(BuildContext context) => SizedBox(height: 48,
    child: ListView.builder(
        scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _genres.length,
        itemBuilder: (_, i) {
          final active = _sel == i;
          return GestureDetector(onTap: () => setState(() => _sel = i),
              child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      color: active ? AppTheme.primary : AppTheme.card,
                      borderRadius: BorderRadius.circular(20),
                      border: active ? null : Border.all(color: Colors.white.withOpacity(0.15))),
                  alignment: Alignment.center,
                  child: Text(_genres[i], style: TextStyle(
                      color: active ? Colors.white : AppTheme.textSecondary, fontSize: 13,
                      fontWeight: active ? FontWeight.w600 : FontWeight.normal))));
        }),
  );
}

// ── MOVIE ROW ────────────────────────────────────────────────
class _MovieRow extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  const _MovieRow({required this.title, required this.movies});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
    SizedBox(height: 160, child: ListView.builder(
      scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: movies.length,
      itemBuilder: (_, i) => _MovieCard(movie: movies[i]),
    )),
  ]);
}

class _MovieCard extends StatelessWidget {
  final Movie movie;
  const _MovieCard({required this.movie});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.push('/home/movie/${movie.id}', extra: movie),
    child: Container(width: 110, margin: const EdgeInsets.only(right: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6),
            child: Stack(fit: StackFit.expand, children: [
              (movie.thumbnailUrl != null && movie.thumbnailUrl!.isNotEmpty)
                  ? CachedNetworkImage(imageUrl: movie.thumbnailUrl!, fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppTheme.card),
                  errorWidget: (_, __, ___) => Container(color: AppTheme.card,
                      child: const Icon(Icons.movie, color: AppTheme.textSecondary)))
                  : Container(color: AppTheme.card),
              if (movie.isPremium) Positioned(top: 4, right: 4,
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(3)),
                      child: const Text('PRO', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)))),
            ]))),
        const SizedBox(height: 4),
        Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
        if (movie.rating != null) Row(children: [
          const Icon(Icons.star, color: Colors.amber, size: 10),
          Text(' ${movie.rating!.toStringAsFixed(1)}',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
        ]),
      ]),
    ),
  );
}

// ── SEARCH TAB ───────────────────────────────────────────────
class _SearchTab extends StatefulWidget {
  const _SearchTab();
  @override State<_SearchTab> createState() => _SearchTabState();
}
class _SearchTabState extends State<_SearchTab> {
  final _ctrl  = TextEditingController();
  final _focus = FocusNode();
  bool _active   = false;
  int  _selGenre = 0;

  final _genres = [
    ('Semua',      null),
    ('Film',       'MOVIE'),
    ('Serial',     'SERIES'),
    ('Dokumenter', 'DOCUMENTARY'),
    ('Anime',      'ANIME'),
  ];

  @override
  void dispose() { _ctrl.dispose(); _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => SafeArea(child: Column(children: [
    Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(children: [
          const Text('Temukan Film', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const Spacer(),
          Consumer<MovieProvider>(builder: (_, movies, __) {
            final count = _active ? movies.searchResults.length : movies.all.length;
            return Text('$count film', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13));
          }),
        ])),
    const SizedBox(height: 12),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(height: 48,
            decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _focus.hasFocus
                    ? AppTheme.primary.withOpacity(0.6) : Colors.white.withOpacity(0.06))),
            child: TextField(
              controller: _ctrl, focusNode: _focus,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              onChanged: (v) {
                setState(() => _active = v.isNotEmpty);
                final api = context.read<AuthProvider>().api;
                context.read<MovieProvider>().search(api, v);
              },
              decoration: InputDecoration(
                  hintText: 'Judul, genre, tahun...',
                  hintStyle: const TextStyle(color: Color(0xFF555555), fontSize: 14),
                  prefixIcon: Icon(_active ? Icons.search : Icons.search_outlined,
                      color: _active ? AppTheme.primary : AppTheme.textSecondary, size: 22),
                  suffixIcon: _active ? IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textSecondary, size: 18),
                      onPressed: () {
                        _ctrl.clear(); setState(() => _active = false);
                        context.read<MovieProvider>().search(context.read<AuthProvider>().api, '');
                      }) : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14)),
            ))),
    const SizedBox(height: 12),
    SizedBox(height: 36,
        child: ListView.builder(
            scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _genres.length,
            itemBuilder: (_, i) {
              final active = _selGenre == i;
              return GestureDetector(onTap: () => setState(() => _selGenre = i),
                  child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                          color: active ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: active ? AppTheme.primary : Colors.white.withOpacity(0.15))),
                      alignment: Alignment.center,
                      child: Text(_genres[i].$1, style: TextStyle(
                          color: active ? Colors.white : AppTheme.textSecondary,
                          fontSize: 12, fontWeight: active ? FontWeight.w600 : FontWeight.normal))));
            })),
    const SizedBox(height: 12),
    Expanded(child: Consumer<MovieProvider>(builder: (_, movies, __) {
      List<Movie> list = _active ? movies.searchResults : movies.all;
      final genreFilter = _genres[_selGenre].$2;
      if (genreFilter != null) {
        list = list.where((m) => m.contentType?.toUpperCase() == genreFilter).toList();
      }
      if (list.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 80, height: 80,
            decoration: BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
            child: const Icon(Icons.movie_filter_outlined, color: AppTheme.textSecondary, size: 36)),
        const SizedBox(height: 16),
        Text(_active ? 'Film "${_ctrl.text}" tidak ditemukan' : 'Belum ada film tersedia',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(_active ? 'Coba kata kunci lain' : 'Film akan muncul setelah admin menambahkan',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13), textAlign: TextAlign.center),
      ]));
      return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, childAspectRatio: 0.58, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: list.length,
          itemBuilder: (_, i) => _GridMovieCard(movie: list[i]));
    })),
  ]));
}

class _GridMovieCard extends StatelessWidget {
  final Movie movie;
  const _GridMovieCard({required this.movie});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.push('/home/movie/${movie.id}', extra: movie),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8),
          child: Stack(fit: StackFit.expand, children: [
            (movie.thumbnailUrl != null && movie.thumbnailUrl!.isNotEmpty)
                ? CachedNetworkImage(imageUrl: movie.thumbnailUrl!, fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppTheme.card),
                errorWidget: (_, __, ___) => Container(color: AppTheme.card,
                    child: const Icon(Icons.movie, color: Colors.white12, size: 32)))
                : Container(color: AppTheme.card,
                child: const Icon(Icons.movie, color: Colors.white12, size: 32)),
            Positioned(bottom: 0, left: 0, right: 0,
                child: Container(height: 60, decoration: BoxDecoration(gradient: LinearGradient(
                    begin: Alignment.bottomCenter, end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.75), Colors.transparent])))),
            if (movie.isPremium) Positioned(top: 6, right: 6,
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                    child: const Text('PRO', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)))),
            if (movie.rating != null) Positioned(bottom: 6, left: 6,
                child: Row(children: [
                  const Icon(Icons.star, color: Colors.amber, size: 11),
                  const SizedBox(width: 2),
                  Text(movie.rating!.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                ])),
          ]))),
      const SizedBox(height: 5),
      Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
      const SizedBox(height: 2),
      Text(movie.contentType ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
    ]),
  );
}

// ════════════════════════════════════════════════════════════
// ── FAVORITES TAB (IMPROVED) ─────────────────────────────────
// ════════════════════════════════════════════════════════════
class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab();
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Consumer<MovieProvider>(builder: (_, movies, __) {
      final favs = movies.favorites.isNotEmpty
          ? movies.favorites
          : movies.all.where((m) => m.isFeatured).toList();

      return Column(children: [
        // ── Header ──
        Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Row(children: [
              const Icon(Icons.favorite, color: AppTheme.primary, size: 22),
              const SizedBox(width: 8),
              const Text('Favorit Saya', style: TextStyle(color: Colors.white,
                  fontSize: 22, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (favs.isNotEmpty)
                Text('${favs.length} film',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            ])),

        if (favs.isEmpty)
          Expanded(child: Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 90, height: 90,
                decoration: BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
                child: const Icon(Icons.favorite_border, color: AppTheme.primary, size: 40)),
            const SizedBox(height: 16),
            const Text('Belum ada favorit', style: TextStyle(color: Colors.white,
                fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Tap ❤️ di halaman detail film\nuntuk menambahkan ke favorit',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.explore_outlined, size: 18),
                label: const Text('Jelajahi Film'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
          ])))
        else
          Expanded(child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              itemCount: favs.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.card),
              itemBuilder: (_, i) => _FavMovieTile(movie: favs[i]))),
      ]);
    }));
  }
}

class _FavMovieTile extends StatelessWidget {
  final Movie movie;
  const _FavMovieTile({required this.movie});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.push('/home/movie/${movie.id}', extra: movie),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Thumbnail
        ClipRRect(borderRadius: BorderRadius.circular(8),
            child: SizedBox(width: 80, height: 110,
                child: (movie.thumbnailUrl != null && movie.thumbnailUrl!.isNotEmpty)
                    ? CachedNetworkImage(imageUrl: movie.thumbnailUrl!, fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(color: AppTheme.card,
                        child: const Icon(Icons.movie, color: Colors.white24)))
                    : Container(color: AppTheme.card,
                    child: const Icon(Icons.movie, color: Colors.white24)))),
        const SizedBox(width: 12),
        // Info
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (movie.isPremium)
            Container(margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4)),
                child: const Text('PREMIUM', style: TextStyle(color: Colors.amber,
                    fontSize: 9, fontWeight: FontWeight.bold))),
          Text(movie.title, style: const TextStyle(color: Colors.white, fontSize: 14,
              fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(children: [
            if (movie.rating != null) ...[
              const Icon(Icons.star, color: Colors.amber, size: 12),
              Text(' ${movie.rating!.toStringAsFixed(1)}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(width: 6),
            ],
            Text('${movie.releaseYear ?? ''}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ]),
          const SizedBox(height: 4),
          Text('${movie.contentType ?? ''} • ${movie.duration ?? ''}',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          const SizedBox(height: 6),
          if (movie.description != null)
            Text(movie.description!, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, height: 1.4)),
        ])),
        const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20),
      ]),
    ),
  );
}

// ════════════════════════════════════════════════════════════
// ── DOWNLOADS TAB (IMPROVED) ─────────────────────────────────
// ════════════════════════════════════════════════════════════
class _DownloadsTab extends StatelessWidget {
  const _DownloadsTab();
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Consumer<MovieProvider>(builder: (_, movies, __) {
      final list = movies.all.where((m) => m.isTrending).toList();

      return Column(children: [
        // ── Header ──
        Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Row(children: [
              const Icon(Icons.download_done, color: AppTheme.primary, size: 22),
              const SizedBox(width: 8),
              const Text('Unduhan Saya', style: TextStyle(color: Colors.white,
                  fontSize: 22, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (list.isNotEmpty)
                TextButton.icon(onPressed: () {},
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 16),
                    label: const Text('Hapus semua',
                        style: TextStyle(color: Colors.red, fontSize: 12))),
            ])),

        if (list.isEmpty)
          Expanded(child: Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 90, height: 90,
                decoration: BoxDecoration(color: AppTheme.card, shape: BoxShape.circle),
                child: const Icon(Icons.download_outlined, color: AppTheme.primary, size: 40)),
            const SizedBox(height: 16),
            const Text('Belum ada unduhan', style: TextStyle(color: Colors.white,
                fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Download film untuk ditonton\ntanpa koneksi internet',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.explore_outlined, size: 18),
                label: const Text('Jelajahi Film'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
          ])))
        else
          Expanded(child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.card),
              itemBuilder: (_, i) => _DownloadMovieTile(movie: list[i], index: i))),
      ]);
    }));
  }
}

class _DownloadMovieTile extends StatelessWidget {
  final Movie movie;
  final int index;
  const _DownloadMovieTile({required this.movie, required this.index});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.push('/home/movie/${movie.id}', extra: movie),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Thumbnail + overlay
        ClipRRect(borderRadius: BorderRadius.circular(8),
            child: SizedBox(width: 80, height: 110,
                child: Stack(fit: StackFit.expand, children: [
                  (movie.thumbnailUrl != null && movie.thumbnailUrl!.isNotEmpty)
                      ? CachedNetworkImage(imageUrl: movie.thumbnailUrl!, fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(color: AppTheme.card))
                      : Container(color: AppTheme.card),
                  Container(color: Colors.black.withOpacity(0.35)),
                  const Center(child: Icon(Icons.download_done, color: Colors.white, size: 26)),
                ]))),
        const SizedBox(width: 12),
        // Info
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(movie.title, style: const TextStyle(color: Colors.white, fontSize: 14,
              fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(children: [
            if (movie.rating != null) ...[
              const Icon(Icons.star, color: Colors.amber, size: 12),
              Text(' ${movie.rating!.toStringAsFixed(1)}',
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(width: 6),
            ],
            Text('${movie.releaseYear ?? ''}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ]),
          const SizedBox(height: 4),
          Text('${movie.contentType ?? ''} • ${movie.duration ?? ''}',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          const SizedBox(height: 6),
          if (movie.description != null)
            Text(movie.description!, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, height: 1.4)),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.storage_outlined, color: AppTheme.textSecondary, size: 12),
            const SizedBox(width: 4),
            Text('${(index + 1) * 127} MB',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          ]),
        ])),
        // Menu
        PopupMenuButton<String>(
          color: AppTheme.surface,
          icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary, size: 20),
          onSelected: (v) {
            if (v == 'play') context.push('/home/movie/${movie.id}', extra: movie);
            if (v == 'delete') ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Film dihapus dari unduhan'),
                    backgroundColor: Colors.red));
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'play', child: Row(children: [
              Icon(Icons.play_arrow, color: Colors.white, size: 16),
              SizedBox(width: 8), Text('Putar', style: TextStyle(color: Colors.white)),
            ])),
            const PopupMenuItem(value: 'delete', child: Row(children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 16),
              SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red)),
            ])),
          ],
        ),
      ]),
    ),
  );
}

// ── PROFILE TAB ──────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();
  @override
  Widget build(BuildContext context) {
    final user      = context.watch<AuthProvider>().user;
    final isPremium = user?.isPremium ?? false;
    return SafeArea(child: SingleChildScrollView(child: Column(children: [
      const SizedBox(height: 24),
      Stack(alignment: Alignment.bottomRight, children: [
        CircleAvatar(radius: 48, backgroundColor: AppTheme.primary,
            child: Text(user?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold))),
        Container(width: 26, height: 26,
            decoration: BoxDecoration(color: AppTheme.card, shape: BoxShape.circle,
                border: Border.all(color: AppTheme.background, width: 2)),
            child: const Icon(Icons.edit, size: 13, color: Colors.white)),
      ]),
      const SizedBox(height: 12),
      Text(user?.name ?? '', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(user?.email ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      const SizedBox(height: 10),
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
              color: isPremium ? Colors.amber.withOpacity(0.15) : AppTheme.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isPremium ? Colors.amber : Colors.white24)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(isPremium ? Icons.star : Icons.star_border,
                color: isPremium ? Colors.amber : AppTheme.textSecondary, size: 14),
            const SizedBox(width: 5),
            Text(isPremium ? 'Premium' : 'Free', style: TextStyle(
                color: isPremium ? Colors.amber : AppTheme.textSecondary,
                fontSize: 12, fontWeight: FontWeight.w600)),
          ])),
      const SizedBox(height: 20),
      if (user?.isAdmin == true) ...[
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(width: double.infinity,
                child: ElevatedButton.icon(
                    onPressed: () => context.push('/admin'),
                    icon: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                    label: const Text('Admin Panel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A5F),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12))))),
        const SizedBox(height: 12),
      ],
      if (!isPremium) ...[
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppTheme.primary.withOpacity(0.8), AppTheme.primary]),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Upgrade ke Premium', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Tonton semua konten tanpa batas', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ])),
                  ElevatedButton(onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                      child: const Text('Upgrade', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                ]))),
        const SizedBox(height: 16),
      ],
      Container(margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            _tile(Icons.person_outline,         'Edit Profil',   () => context.push('/profile')),
            _div(),
            _tile(Icons.notifications_outlined, 'Notifikasi',    () {}),
            _div(),
            _tile(Icons.language_outlined,      'Bahasa',        () {}, sub: 'Indonesia'),
            _div(),
            _tile(Icons.help_outline,           'Bantuan',       () {}),
            _div(),
            _tile(Icons.info_outline,           'Tentang Aflix', () {}),
          ])),
      const SizedBox(height: 16),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(width: double.infinity,
              child: OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
                      backgroundColor: AppTheme.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      title: const Text('Keluar', style: TextStyle(color: Colors.white)),
                      content: const Text('Yakin ingin keluar dari Aflix?', style: TextStyle(color: AppTheme.textSecondary)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                        ElevatedButton(onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Keluar', style: TextStyle(color: Colors.white))),
                      ],
                    ));
                    if (ok == true && context.mounted) {
                      await context.read<AuthProvider>().logout();
                      if (context.mounted) context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.red, size: 18),
                  label: const Text('Keluar', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red, width: 0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12))))),
      const SizedBox(height: 100),
    ])));
  }

  Widget _tile(IconData icon, String label, VoidCallback onTap, {String? sub}) =>
      ListTile(leading: Icon(icon, color: AppTheme.textSecondary, size: 22),
          title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            if (sub != null) Text(sub, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Color(0xFF444444), size: 20),
          ]), onTap: onTap);

  Widget _div() => const Divider(height: 0.5, color: AppTheme.card, indent: 16, endIndent: 16);
}

// ── SHARED ────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.wifi_off_outlined, color: AppTheme.textSecondary, size: 64),
        const SizedBox(height: 16),
        const Text('Tidak bisa terhubung ke server', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text('Pastikan XAMPP & Spring Boot berjalan\ndi port 8080', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Coba Lagi')),
      ])));
}