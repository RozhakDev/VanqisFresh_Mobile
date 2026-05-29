import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../data/repositories/auth_repository.dart';

/// Menampilkan halaman lupa kata sandi.
///
/// Digunakan pengguna untuk meminta kode reset kata sandi ke email mereka.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  /// Membuat instance halaman lupa kata sandi.
  const ForgotPasswordScreen({super.key});

  /// Menginisialisasi state untuk halaman lupa kata sandi.
  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;

  /// Membersihkan sumber daya controller saat layar ditutup.
  ///
  /// Mencegah kebocoran memori dari input teks.
  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  /// Mengirimkan permintaan OTP ke email yang dimasukkan.
  ///
  /// Memvalidasi form terlebih dahulu sebelum memanggil API.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final msg = await ref.read(authRepositoryProvider).requestPasswordReset(_emailCtrl.text.trim());
      if (!mounted) return;
      SnackbarUtils.show(context, msg, type: SnackbarType.success);
      context.push('/reset-password?email=${_emailCtrl.text.trim()}');
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.show(context, e.toString().replaceAll('Exception: ', ''), type: SnackbarType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Membangun antarmuka utama halaman lupa kata sandi.
  ///
  /// Digunakan oleh Flutter untuk merender UI terbaru.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
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
                  'Lupa Kata Sandi?',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masukkan email yang terdaftar untuk menerima kode OTP.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Text(
                    'Alamat Email',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
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
                
                const SizedBox(height: 48),

                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.textOnPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Kirim Kode OTP'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
