import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final _fk    = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _obscure = true, _emailErr = false, _passErr = false;

  @override void dispose() { _email.dispose(); _pass.dispose(); super.dispose(); }

  Future<void> _submit() async {
    setState(() { _emailErr = false; _passErr = false; });
    if (!_fk.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok   = await auth.login(_email.text.trim(), _pass.text);
    if (!mounted) return;
    if (ok) { context.go('/home'); return; }
    final err = (auth.error ?? '').toLowerCase();
    setState(() {
      _emailErr = err.contains('email') || err.contains('user') || err.contains('found');
      _passErr  = err.contains('password') || err.contains('salah') || err.contains('invalid');
      if (!_emailErr && !_passErr) _passErr = true;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    body: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(children: [
        const SizedBox(height: 60),
        // Logo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(6)),
          child: const Text('AFLIX', style: TextStyle(color: Colors.white,
              fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 6)),
        ),
        const SizedBox(height: 36),
        // Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12)),
          child: Form(key: _fk, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _lbl('Email'), const SizedBox(height: 6),
            TextFormField(
              controller: _email, keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: _deco('your@email.com', Icons.email_outlined, _emailErr),
              validator: (v) => (v == null || v.isEmpty || !v.contains('@')) ? '' : null,
              onChanged: (_) => setState(() => _emailErr = false),
            ),
            if (_emailErr) _errWidget('Email tidak ditemukan'),
            const SizedBox(height: 16),
            _lbl('Password'), const SizedBox(height: 6),
            TextFormField(
              controller: _pass, obscureText: _obscure,
              style: const TextStyle(color: Colors.white),
              decoration: _deco('Password', Icons.lock_outline, _passErr,
                suffix: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppTheme.textSecondary, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure))),
              validator: (v) => (v == null || v.length < 6) ? '' : null,
              onChanged: (_) => setState(() => _passErr = false),
            ),
            if (_passErr) _errWidget('Password salah. Coba lagi.'),
            const SizedBox(height: 6),
            Align(alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/forgot-password'),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text('Lupa password?', style: TextStyle(color: AppTheme.primary, fontSize: 13)))),
            const SizedBox(height: 16),
            Consumer<AuthProvider>(builder: (_, auth, __) =>
              SizedBox(width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))))),
            const SizedBox(height: 20),
            // OR divider
            Row(children: [
              Expanded(child: Divider(color: Colors.white.withOpacity(0.12))),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('OR', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
              Expanded(child: Divider(color: Colors.white.withOpacity(0.12))),
            ]),
            const SizedBox(height: 16),
            // Facebook
            SizedBox(width: double.infinity, height: 48,
              child: OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text('Facebook login coming soon!'),
                    backgroundColor: const Color(0xFF1877F2), behavior: SnackBarBehavior.floating)),
                icon: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 22),
                label: const Text('Continue with Facebook', style: TextStyle(color: Colors.white, fontSize: 14)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))))),
          ])),
        ),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('Belum punya akun? ', style: TextStyle(color: AppTheme.textSecondary)),
          GestureDetector(
            onTap: () => context.push('/register'),
            child: const Text('Daftar Sekarang', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 32),
      ]),
    )),
  );

  Widget _lbl(String t) => Text(t, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500));
  Widget _errWidget(String msg) => Padding(padding: const EdgeInsets.only(top: 5),
    child: Row(children: [
      const Icon(Icons.error_outline, color: Color(0xFFFF453A), size: 13),
      const SizedBox(width: 4),
      Text(msg, style: const TextStyle(color: Color(0xFFFF453A), fontSize: 12)),
    ]));

  InputDecoration _deco(String hint, IconData icon, bool hasErr, {Widget? suffix}) =>
    InputDecoration(
      hintText: hint, hintStyle: const TextStyle(color: Color(0xFF555555), fontSize: 14),
      filled: true, fillColor: AppTheme.card,
      prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20), suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: hasErr ? const BorderSide(color: Color(0xFFFF453A), width: 1.5) : BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: hasErr ? const Color(0xFFFF453A) : AppTheme.primary, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFF453A), width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFF453A), width: 1.5)),
      errorStyle: const TextStyle(height: 0, fontSize: 0));
}
