import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override State<ForgotPasswordScreen> createState() => _ForgotState();
}

class _ForgotState extends State<ForgotPasswordScreen> {
  int _step = 0; // 0=email, 1=new password
  final _emailCtrl = TextEditingController();
  final _pass1     = TextEditingController();
  final _pass2     = TextEditingController();
  bool _obs1 = true, _obs2 = true, _loading = false;

  @override void dispose() { _emailCtrl.dispose(); _pass1.dispose(); _pass2.dispose(); super.dispose(); }

  Future<void> _sendReset() async {
    if (!_emailCtrl.text.contains('@')) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _loading = false; _step = 1; });
  }

  Future<void> _setNewPass() async {
    if (_pass1.text.length < 6 || _pass1.text != _pass2.text) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);
    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 64, height: 64,
          decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 36)),
        const SizedBox(height: 16),
        const Text('Password berhasil diubah!', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text('Silakan login dengan password baru.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity,
          child: ElevatedButton(onPressed: () { Navigator.pop(context); context.go('/login'); },
            child: const Text('Login Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
        onPressed: () => _step == 1 ? setState(() => _step = 0) : context.pop()),
      title: Text(_step == 0 ? 'Lupa Password' : 'Password Baru',
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      centerTitle: true,
    ),
    body: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: _step == 0 ? _emailStep() : _newPassStep(),
    )),
  );

  Widget _emailStep() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SizedBox(height: 16),
    Container(width: 64, height: 64,
      decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), shape: BoxShape.circle),
      child: const Icon(Icons.lock_reset_outlined, color: AppTheme.primary, size: 32)),
    const SizedBox(height: 20),
    const Text('Reset Password', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const Text('Masukkan email terdaftar untuk reset password.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5)),
    const SizedBox(height: 28),
    _lbl('Email'), const SizedBox(height: 6),
    TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white), decoration: _deco('your@email.com', Icons.email_outlined)),
    const SizedBox(height: 28),
    SizedBox(width: double.infinity, height: 48,
      child: ElevatedButton(onPressed: _loading ? null : _sendReset,
        child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text('Kirim Link Reset', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)))),
  ]);

  Widget _newPassStep() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SizedBox(height: 16),
    Container(width: 64, height: 64,
      decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), shape: BoxShape.circle),
      child: const Icon(Icons.key_outlined, color: AppTheme.primary, size: 32)),
    const SizedBox(height: 20),
    const Text('Password Baru', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const Text('Minimal 6 karakter.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
    const SizedBox(height: 28),
    _lbl('Password Baru'), const SizedBox(height: 6),
    TextField(controller: _pass1, obscureText: _obs1, style: const TextStyle(color: Colors.white),
      decoration: _deco('Min. 6 karakter', Icons.lock_outline, suffix: IconButton(
        icon: Icon(_obs1 ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textSecondary, size: 20),
        onPressed: () => setState(() => _obs1 = !_obs1)))),
    const SizedBox(height: 16),
    _lbl('Konfirmasi'), const SizedBox(height: 6),
    TextField(controller: _pass2, obscureText: _obs2, style: const TextStyle(color: Colors.white),
      decoration: _deco('Ulangi password', Icons.lock_outline, suffix: IconButton(
        icon: Icon(_obs2 ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textSecondary, size: 20),
        onPressed: () => setState(() => _obs2 = !_obs2)))),
    const SizedBox(height: 28),
    SizedBox(width: double.infinity, height: 48,
      child: ElevatedButton(onPressed: _loading ? null : _setNewPass,
        child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text('Simpan Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)))),
  ]);

  Widget _lbl(String t) => Text(t, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500));

  InputDecoration _deco(String hint, IconData icon, {Widget? suffix}) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(color: Color(0xFF555555), fontSize: 14),
    filled: true, fillColor: AppTheme.card,
    prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20), suffixIcon: suffix,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)));
}
