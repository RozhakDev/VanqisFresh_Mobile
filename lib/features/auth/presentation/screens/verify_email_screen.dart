import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../data/repositories/auth_repository.dart';

/// Menampilkan halaman untuk alur pengguna terkait.
///
/// Halaman ini mengatur tampilan dan interaksi utama fitur tersebut.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat VerifyEmailScreen perlu dibuat dengan nilai awal.
  const VerifyEmailScreen({super.key, required this.email});

  /// Membuat state yang mengelola perilaku widget.
  ///
  /// State ini menyimpan interaksi dan perubahan lokal widget.
  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

/// Menampilkan halaman untuk alur pengguna terkait.
///
/// Halaman ini mengatur tampilan dan interaksi utama fitur tersebut.
class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  int _resendTimeout = 60;
  Timer? _timer;

  /// Menyiapkan state awal saat widget dibuat.
  ///
  /// Digunakan untuk inisialisasi sebelum tampilan pertama dirender.
  @override
  void initState() {
    super.initState();
    _startTimer();
    _otpController.addListener(() {
      setState(() {});
    });
  }

  /// Membersihkan resource saat widget tidak lagi digunakan.
  ///
  /// Dipanggil untuk melepas controller, listener, atau timer.
  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  /// Memulai timer sebelum OTP dapat dikirim ulang.
  ///
  /// Timer membantu membatasi aksi kirim ulang kode.
  void _startTimer() {
    setState(() => _resendTimeout = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimeout == 0) {
        timer.cancel();
      } else {
        setState(() => _resendTimeout--);
      }
    });
  }

  /// Memverifikasi OTP yang dimasukkan pengguna.
  ///
  /// Dipakai saat pengguna menyelesaikan verifikasi email.
  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      SnackbarUtils.show(context, 'Kode verifikasi belum lengkap.', type: SnackbarType.error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authRepositoryProvider).verifyEmail(widget.email, otp);
      if (!mounted) return;
      SnackbarUtils.show(context, 'Verifikasi berhasil! Silakan masuk.', type: SnackbarType.success);
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.show(context, e.toString().replaceAll('Exception: ', ''), type: SnackbarType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Mengirim ulang kode OTP ke email pengguna.
  ///
  /// Digunakan saat pengguna meminta kode baru.
  Future<void> _resendOtp() async {
    if (_resendTimeout > 0) return;
    
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).resendOtp(widget.email);
      if (!mounted) return;
      SnackbarUtils.show(context, 'Kode verifikasi telah dikirim ulang.', type: SnackbarType.success);
      _startTimer();
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.show(context, e.toString().replaceAll('Exception: ', ''), type: SnackbarType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Membangun tampilan berdasarkan context dan state saat ini.
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
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: AppColors.primaryMuted, shape: BoxShape.circle),
                child: const Icon(Icons.mark_email_read_rounded, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'Verifikasi Email Anda',
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Kami telah mengirimkan 6 digit kode OTP ke alamat\n${widget.email}',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      final text = _otpController.text;
                      final isFilled = index < text.length;
                      final isFocused = index == text.length;
                      
                      return Container(
                        width: 48,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isFocused ? AppColors.primary : (isFilled ? AppColors.primary.withValues(alpha: 0.5) : AppColors.border),
                            width: isFocused ? 2 : 1,
                          ),
                          boxShadow: isFocused ? AppColors.softShadow : [],
                        ),
                        child: Text(
                          isFilled ? text[index] : '',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    }),
                  ),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    cursorColor: Colors.transparent,
                    enableInteractiveSelection: false,
                    style: const TextStyle(color: Colors.transparent, fontSize: 24),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                      filled: true,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading || _otpController.text.length < 6 ? null : _verifyOtp,
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
                        child: CircularProgressIndicator(color: AppColors.textOnPrimary, strokeWidth: 2)
                      )
                    : const Text('Verifikasi Sekarang'),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Belum menerima kode? ', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                  GestureDetector(
                    onTap: _isLoading ? null : _resendOtp,
                    child: Text(
                      _resendTimeout > 0 ? 'Tunggu ${_resendTimeout}s' : 'Kirim Ulang',
                      style: GoogleFonts.inter(
                        color: _resendTimeout > 0 ? AppColors.textHint : AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
