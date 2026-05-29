import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../data/repositories/auth_repository.dart';

/// Menampilkan halaman pengaturan ulang kata sandi.
///
/// Digunakan pengguna untuk memasukkan kode OTP dan menyetel kata sandi baru.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;

  /// Membuat instance halaman pengaturan ulang kata sandi.
  ///
  /// Memerlukan data email untuk validasi dengan kode OTP di server.
  const ResetPasswordScreen({super.key, required this.email});

  /// Menginisialisasi state untuk halaman pengaturan ulang sandi.
  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  /// Membersihkan memori saat halaman dihancurkan.
  ///
  /// Memastikan controller teks dihapus dengan aman.
  @override
  void dispose() {
    _otpCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// Memverifikasi OTP dan menyimpan kata sandi baru ke server.
  ///
  /// Menavigasi kembali ke halaman masuk jika berhasil.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final msg = await ref.read(authRepositoryProvider).confirmPasswordReset(
        email: widget.email,
        otpCode: _otpCtrl.text.trim(),
        newPassword: _passwordCtrl.text,
      );
      if (!mounted) return;
      SnackbarUtils.show(context, msg, type: SnackbarType.success);
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.show(context, e.toString().replaceAll('Exception: ', ''), type: SnackbarType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Merender tata letak UI halaman reset kata sandi.
  ///
  /// Digunakan oleh Flutter untuk menampilkan widget terbaru.
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
                  'Buat Sandi Baru',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kode OTP telah dikirimkan ke ${widget.email}. Silakan periksa kotak masuk Anda.',
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
                    'Kode OTP',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                TextFormField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 6,
                  style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w500, letterSpacing: 8, fontSize: 18),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: '000000',
                    hintStyle: TextStyle(letterSpacing: 8),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'OTP wajib diisi';
                    if (value.length < 6) return 'OTP harus 6 digit';
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Text(
                    'Kata Sandi Baru',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: '••••••••',
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
                    if (value == null || value.isEmpty) return 'Kata sandi baru wajib diisi';
                    if (value.length < 8) return 'Kata sandi minimal 8 karakter';
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
                      : const Text('Simpan Kata Sandi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
