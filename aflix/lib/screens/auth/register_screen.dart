import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegState();
}

class _RegState extends State<RegisterScreen> {
  final _fk      = GlobalKey<FormState>();
  final _name    = TextEditingController();
  final _email   = TextEditingController();
  final _pass    = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure1 = true, _obscure2 = true;

  @override void dispose() {
    _name.dispose(); _email.dispose(); _pass.dispose(); _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_fk.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok   = await auth.register(_name.text.trim(), _email.text.trim(), _pass.text);
    if (!mounted) return;
    if (ok) context.go('/home');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
        onPressed: () => context.pop()),
      title: const Text('Buat Akun Baru', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      centerTitle: true,
    ),
    body: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(5)),
          child: const Text('AFLIX', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 4)),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12)),
          child: Form(key: _fk, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _lbl('Nama Lengkap'), const SizedBox(height: 6),
            _field(_name, 'Nama kamu', Icons.person_outline),
            const SizedBox(height: 16),
            _lbl('Email'), const SizedBox(height: 6),
            _field(_email, 'your@email.com', Icons.email_outlined,
              type: TextInputType.emailAddress,
              validator: (v) => (v == null || !v.contains('@')) ? '' : null),
            const SizedBox(height: 16),
            _lbl('Password'), const SizedBox(height: 6),
            _field(_pass, 'Min. 6 karakter', Icons.lock_outline,
              obscure: _obscure1, toggleObscure: () => setState(() => _obscure1 = !_obscure1),
              validator: (v) => (v == null || v.length < 6) ? '' : null),
            const SizedBox(height: 16),
            _lbl('Konfirmasi Password'), const SizedBox(height: 6),
            _field(_confirm, 'Ulangi password', Icons.lock_outline,
              obscure: _obscure2, toggleObscure: () => setState(() => _obscure2 = !_obscure2),
              validator: (v) => (v != _pass.text) ? '' : null),
            Consumer<AuthProvider>(builder: (_, auth, __) {
              if (auth.error == null) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.4))),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 16), const SizedBox(width: 8),
                  Expanded(child: Text(auth.error!, style: const TextStyle(color: Colors.red, fontSize: 12))),
                ]),
              );
            }),
            const SizedBox(height: 24),
            Consumer<AuthProvider>(builder: (_, auth, __) =>
              SizedBox(width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Buat Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))))),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Sudah punya akun? ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              GestureDetector(onTap: () => context.pop(),
                child: const Text('Masuk', style: TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.bold))),
            ]),
          ])),
        ),
        const SizedBox(height: 32),
      ]),
    )),
  );

  Widget _lbl(String t) => Text(t, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500));

  Widget _field(TextEditingController ctrl, String hint, IconData icon, {
    TextInputType? type, bool obscure = false, VoidCallback? toggleObscure,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: ctrl, obscureText: obscure, keyboardType: type,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: hint, hintStyle: const TextStyle(color: Color(0xFF555555), fontSize: 14),
      filled: true, fillColor: AppTheme.card,
      prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
      suffixIcon: toggleObscure != null ? IconButton(
        icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppTheme.textSecondary, size: 20), onPressed: toggleObscure) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFF453A), width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFF453A), width: 1.5)),
      errorStyle: const TextStyle(height: 0, fontSize: 0)),
    validator: validator ?? (v) => (v == null || v.trim().isEmpty) ? '' : null,
  );
}
