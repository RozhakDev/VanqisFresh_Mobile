import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _addressCtrl;

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

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profil berhasil diperbarui!',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
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
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Data pengguna tidak ditemukan')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textOnPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Profil & Akun',
          style: GoogleFonts.inter(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '@${user.username}',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Bergabung bersama VanqisFresh',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Nama Depan'),
                          TextFormField(
                            controller: _firstNameCtrl,
                            decoration: const InputDecoration(hintText: 'Rozhak'),
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
                            decoration: const InputDecoration(hintText: 'Dev'),
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
                  decoration: const InputDecoration(
                    hintText: '083847921480',
                    prefixIcon: Icon(Icons.phone_android_rounded, color: AppColors.textHint, size: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Nomor HP wajib diisi';
                    final phone = value.trim();
                    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) return 'Format angka saja';
                    if (phone.length < 10 || phone.length > 15) return 'Panjang 10 - 15 digit angka';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildLabel('Email (Opsional)'),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'rozhak@rozhak.xyz',
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.textHint, size: 20),
                  ),
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
                  decoration: const InputDecoration(
                    hintText: 'Detail jalan, RT/RW, Kecamatan, dsb.',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Alamat wajib diisi';
                    if (value.trim().length < 10) return 'Tulis alamat lebih detail';
                    return null;
                  },
                ),
                const SizedBox(height: 48),

                ElevatedButton(
                  onPressed: authState.isLoading ? null : _onUpdateProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.textPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Simpan Pembaruan'),
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
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}