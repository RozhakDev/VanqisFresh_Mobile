import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _emailCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    FocusScope.of(context).unfocus();

    final success = await ref.read(authProvider.notifier).register(
          username: _usernameCtrl.text.trim(),
          password: _passwordCtrl.text,
          email: _emailCtrl.text.trim(),
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          phoneNumber: _phoneCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registrasi berhasil! Silakan verifikasi email Anda.',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.success,
        ),
      );
      final registeredEmail = _emailCtrl.text.trim();
      context.go('/verify-email?email=$registeredEmail');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.error!, 
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)
            ),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Buat Akun',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lengkapi data dirimu untuk mulai belanja di VanqisFresh.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                _buildLabel('Username (Unik)'),
                TextFormField(
                  controller: _usernameCtrl,
                  style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  decoration: const InputDecoration(
                    hintText: 'vanqis.fresh',
                    prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.textHint, size: 22),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Username wajib diisi';
                    if (value.trim().length < 4) return 'Username minimal 4 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Nama Depan'),
                          TextFormField(
                            controller: _firstNameCtrl,
                            style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                            decoration: const InputDecoration(hintText: 'Vanqis'),
                            validator: (value) => value == null || value.trim().isEmpty 
                                ? 'Wajib diisi' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Nama Belakang'),
                          TextFormField(
                            controller: _lastNameCtrl,
                            style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                            decoration: const InputDecoration(hintText: 'Fresh'),
                            validator: (value) => value == null || value.trim().isEmpty 
                                ? 'Wajib diisi' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildLabel('Nomor WhatsApp / HP'),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  decoration: const InputDecoration(
                    hintText: '08xxxxxxxx',
                    prefixIcon: Icon(Icons.phone_android_rounded, color: AppColors.textHint, size: 22),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Nomor HP wajib diisi';
                    final phone = value.trim();
                    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) return 'Format angka saja';
                    if (phone.length < 10 || phone.length > 15) return 'Pajang 10 - 15 digit angka';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildLabel('Alamat Email'),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  decoration: const InputDecoration(
                    hintText: 'user@vanqisfresh.com',
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.textHint, size: 22),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildLabel('Kata Sandi'),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Minimal 6 karakter',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textHint, size: 22),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: AppColors.textHint,
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Kata sandi wajib diisi';
                    if (value.length < 6) return 'Minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildLabel('Alamat Lengkap'),
                TextFormField(
                  controller: _addressCtrl,
                  maxLines: 3,
                  style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Jl. Dipayuda No. 1, RT 01/RW 02, Banjarnegara',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Alamat wajib diisi';
                    if (value.trim().length < 10) return 'Tulis alamat lebih detail';
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: authState.isLoading ? null : _onRegister,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.textOnPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Daftar Sekarang',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text(
                        'Masuk di sini',
                        style: GoogleFonts.inter(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}