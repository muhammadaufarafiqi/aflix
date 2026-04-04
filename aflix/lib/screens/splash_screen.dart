import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    // Animasi
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fade = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _scale = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Navigasi aman
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final auth = context.read<AuthProvider>();

    // Tunggu sampai Auth selesai init
    while (!auth.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (!mounted) return;

    if (auth.isLoggedIn) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "AFLIX",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 12),



                    SizedBox(height: 40),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}