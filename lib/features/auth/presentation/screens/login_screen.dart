import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../providers/auth_provider.dart';

/// Menampilkan halaman untuk alur pengguna terkait.
///
/// Halaman ini mengatur tampilan dan interaksi utama fitur tersebut.
class LoginScreen extends ConsumerStatefulWidget {
  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat LoginScreen perlu dibuat dengan nilai awal.
  const LoginScreen({super.key});

  /// Membuat state yang mengelola perilaku widget.
  ///
  /// State ini menyimpan interaksi dan perubahan lokal widget.
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

/// Menampilkan halaman untuk alur pengguna terkait.
///
/// Halaman ini mengatur tampilan dan interaksi utama fitur tersebut.
class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _messageShown = false;

  /// Menyiapkan state awal saat widget dibuat.
  ///
  /// Digunakan untuk inisialisasi sebelum tampilan pertama dirender.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkMessage();
    });
  }

  /// Memeriksa pesan dari route dan menampilkannya bila tersedia.
  ///
  /// Digunakan untuk memberi konteks setelah pengguna diarahkan.
  void _checkMessage() {
    if (!mounted || _messageShown) return;
    
    final message = GoRouterState.of(context).uri.queryParameters['message'];
    if (message != null && message.isNotEmpty) {
      _messageShown = true;
      SnackbarUtils.show(context, message, type: SnackbarType.info);
    }
  }

  /// Membersihkan resource saat widget tidak lagi digunakan.
  ///
  /// Dipanggil untuk melepas controller, listener, atau timer.
  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// Menangani aksi pengguna saat login.
  ///
  /// Validasi dan request login dipicu dari method ini.
  void _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    FocusScope.of(context).unfocus();

    final success = await ref.read(authProvider.notifier).login(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );

    if (!mounted) return;

    if (success) {
      SnackbarUtils.show(context, 'Berhasil masuk!', type: SnackbarType.success);
      context.go('/'); 
    }
  }

  /// Membangun tampilan berdasarkan context dan state saat ini.
  ///
  /// Digunakan oleh Flutter untuk merender UI terbaru.
  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next.error != null) {
        if (next.error!.startsWith('UNVERIFIED:')) {
          final unverifiedEmail = next.error!.split(':')[1];
          ref.read(authProvider.notifier).clearError();
          SnackbarUtils.show(context, 'Email belum diverifikasi. Lanjut ke verifikasi!', type: SnackbarType.warning);
          context.go('/verify-email?email=$unverifiedEmail');
          return;
        }

        SnackbarUtils.show(context, next.error!, type: SnackbarType.error);
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
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary, size: 26),
          onPressed: () => context.go('/'),
          tooltip: 'Batal dan kembali ke Beranda',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Selamat Datang di\nVanqisFresh',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Silakan masuk ke akun Anda untuk mulai berbelanja.',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),

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
                  const SizedBox(height: 24),

                  _buildLabel('Kata Sandi'),
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
                      if (value == null || value.isEmpty) return 'Kata sandi wajib diisi';
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Lupa Kata Sandi?',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _onLogin,
                    style: ElevatedButton.styleFrom(
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
                        : const Text('Masuk Sekarang'),
                  ),
                  
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: Text(
                          'Daftar di sini',
                          style: GoogleFonts.inter(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  /// Menampilkan label input dengan gaya yang konsisten.
  ///
  /// Dipakai oleh field form pada halaman terkait.
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
