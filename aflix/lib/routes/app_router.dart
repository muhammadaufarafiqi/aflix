import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../models/movie.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/movie/movie_detail_screen.dart';
import '../screens/player/video_player_screen.dart';
import '../screens/admin/admin_screen.dart';
// IMPORT BARU UNTUK PROFILE
import '../screens/profile/profile_screen.dart';

class AppRouter {
  final AuthProvider auth;
  AppRouter(this.auth);

  late final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: auth,

    redirect: (ctx, state) {
      if (!auth.isInitialized) return null;

      final loc      = state.matchedLocation;
      final loggedIn = auth.isLoggedIn;

      // Pengecekan admin sesuai model User Anda
      final isAdmin  = auth.user?.role?.toString().contains('ADMIN') ?? false;
      final onAuth   = ['/login', '/register', '/forgot-password'].contains(loc);

      if (!loggedIn && !onAuth && loc != '/splash') {
        return '/login';
      }

      if (loggedIn && onAuth) {
        return '/home';
      }

      if (loggedIn && (loc == '/splash' || loc == '/')) {
        return '/home';
      }

      if (loc == '/admin' && !isAdmin) {
        return '/home';
      }

      return null;
    },

    routes: [
      GoRoute(path: '/splash',          builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login',           builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register',        builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/admin',           builder: (_, __) => const AdminScreen()),

      // RUTE BARU UNTUK PROFILE (STEP 5 & 6)
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
      ),

      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'movie/:id',
            builder: (_, state) => MovieDetailScreen(
              movieId: int.parse(state.pathParameters['id']!),
              movie: state.extra as Movie?,
            ),
          ),
        ],
      ),

      GoRoute(
        path: '/player',
        builder: (_, state) {
          final args = state.extra as Map<String, dynamic>;
          return VideoPlayerScreen(
            title: args['title'],
            videoUrl: args['videoUrl'],
            movieId: args['movieId'],
          );
        },
      ),
    ],
  );
}