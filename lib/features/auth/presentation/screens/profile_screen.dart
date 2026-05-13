import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanqisfresh/core/widgets/main_bottom_nav_bar.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../providers/auth_provider.dart';

/// Menampilkan halaman untuk alur pengguna terkait.
///
/// Halaman ini mengatur tampilan dan interaksi utama fitur tersebut.
class ProfileScreen extends ConsumerStatefulWidget {
  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat ProfileScreen perlu dibuat dengan nilai awal.
  const ProfileScreen({super.key});

  /// Membuat state yang mengelola perilaku widget.
  ///
  /// State ini menyimpan interaksi dan perubahan lokal widget.
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

/// Menampilkan halaman untuk alur pengguna terkait.
///
/// Halaman ini mengatur tampilan dan interaksi utama fitur tersebut.
class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _addressCtrl;

  /// Menyiapkan state awal saat widget dibuat.
  ///
  /// Digunakan untuk inisialisasi sebelum tampilan pertama dirender.
  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    
    _firstNameCtrl = TextEditingController(text: user?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: user?.lastName ?? '');
    _phoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _addressCtrl = TextEditingController(text: user?.address ?? '');
  }

  /// Membersihkan resource saat widget tidak lagi digunakan.
  ///
  /// Dipanggil untuk melepas controller, listener, atau timer.
  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  /// Menangani aksi pengguna saat memperbarui profil.
  ///
  /// Data form dikirim setelah validasi berhasil.
  void _onUpdateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    FocusScope.of(context).unfocus();

    final updateData = <String, dynamic>{
      'first_name': _firstNameCtrl.text.trim(),
      'last_name': _lastNameCtrl.text.trim(),
      'phone_number': _phoneCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
    };

    final success = await ref.read(authProvider.notifier).updateProfile(updateData);

    if (!mounted) return;

    if (success) {
      SnackbarUtils.show(context, 'Profil berhasil diperbarui!', type: SnackbarType.success);
    }
  }

  /// Menangani aksi pengguna saat logout.
  ///
  /// Digunakan untuk menutup sesi pengguna dari halaman profil.
  void _onLogout() {
    ref.read(authProvider.notifier).logout();
    SnackbarUtils.show(context, 'Berhasil keluar!', type: SnackbarType.success);
    context.go('/login');
  }

  /// Membangun tampilan berdasarkan context dan state saat ini.
  ///
  /// Digunakan oleh Flutter untuk merender UI terbaru.
  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next.error != null) {
        SnackbarUtils.show(context, next.error!, type: SnackbarType.error);
        ref.read(authProvider.notifier).clearError();
      }

      if (previous?.user == null && next.user != null) {
        _firstNameCtrl.text = next.user!.firstName;
        _lastNameCtrl.text = next.user!.lastName;
        _phoneCtrl.text = next.user!.phoneNumber ?? '';
        _emailCtrl.text = next.user!.email;
        _addressCtrl.text = next.user!.address ?? '';
      }
    });

    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      if (authState.isLoading) {
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: Center(
          child: Text(
            'Data pengguna tidak ditemukan',
            style: GoogleFonts.inter(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Profil Saya',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: _onLogout,
            tooltip: 'Keluar',
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: MainBottomNavBar(currentIndex: 3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.primaryMuted,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                            style: GoogleFonts.inter(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${user.firstName} ${user.lastName}'.trim(),
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.section,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '@${user.username}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                Text(
                  'Data Pribadi',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
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
                            decoration: _buildInputDecoration('Vanqis', Icons.person_outline_rounded),
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
                            decoration: _buildInputDecoration('Fresh', Icons.person_outline_rounded),
                            validator: (value) => value == null || value.trim().isEmpty 
                                ? 'Wajib diisi' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildLabel('Nomor WhatsApp / HP'),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: _buildInputDecoration('08xxxxxxxx', Icons.phone_android_rounded),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Nomor HP wajib diisi';
                    final phone = value.trim();
                    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) return 'Format angka saja';
                    if (phone.length < 10 || phone.length > 15) return 'Panjang 10 - 15 digit angka';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildLabel('Email'),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration('user@vanqisfresh.com', Icons.email_outlined),
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildLabel('Alamat Lengkap Pengiriman'),
                TextFormField(
                  controller: _addressCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Jl. Dipayuda No. 1, RT 01/RW 02, Banjarnegara',
                    hintStyle: GoogleFonts.inter(color: AppColors.textHint, fontSize: 14),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Alamat wajib diisi';
                    if (value.trim().length < 10) return 'Tulis alamat lebih detail';
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: authState.isLoading ? null : _onUpdateProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Simpan Pembaruan',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(height: 32),
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
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// Menyiapkan dekorasi input agar tampil konsisten.
  ///
  /// Digunakan untuk menyamakan gaya form.
  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: AppColors.textHint, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}
