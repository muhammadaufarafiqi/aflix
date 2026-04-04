import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/movie_provider.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  // Wajib dipanggil sebelum inisialisasi async lainnya
  WidgetsFlutterBinding.ensureInitialized();

  // Mengunci orientasi layar
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const AflixApp());
}

class AflixApp extends StatelessWidget {
  const AflixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider utama untuk Auth: Secara otomatis menjalankan _init() -> _restore()
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Provider untuk data Film
        ChangeNotifierProvider(create: (_) => MovieProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, __) {

          // JIKA AUTH BELUM SELESAI RESTORE DATA (INITIALIZING)
          // Tampilkan loading screen atau layar hitam agar router tidak
          // terburu-buru melempar user ke halaman login.
          if (!auth.isInitialized) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.dark,
              home: const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Colors.red),
                ),
              ),
            );
          }

          // Sinkronisasi Token: Pastikan ApiService selalu sinkron dengan token terbaru
          auth.api.setToken(auth.token);

          return MaterialApp.router(
            title: 'Aflix',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            // Router sekarang mendapatkan status auth yang sudah 'isInitialized'
            routerConfig: AppRouter(auth).router,
          );
        },
      ),
    );
  }
}