import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/repositories/order_repository.dart';

final paymentMethodsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.watch(orderRepositoryProvider).getPaymentMethods();
});

class PaymentScreen extends ConsumerStatefulWidget {
  final String publicId;

  const PaymentScreen({super.key, required this.publicId});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  File? _selectedImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProof() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    try {
      await ref.read(orderRepositoryProvider).uploadPaymentProof(widget.publicId, _selectedImage!.path);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pembayaran berhasil dikonfirmasi!', style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: AppColors.success,
        ),
      );
      
      context.go('/');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', ''), style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(paymentMethodsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text('Pembayaran', style: GoogleFonts.inter(color: AppColors.textOnPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Pesanan Berhasil Dibuat!', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryDark), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('ID: ${widget.publicId}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 32),

              Text('Pilih Metode Pembayaran', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              
              paymentsAsync.when(
                data: (methods) => methods.isEmpty 
                  ? const Text('Belum ada metode pembayaran yang dikonfigurasi admin.')
                  : Column(
                      children: methods.map((m) {
                        final hasQr = m['qr_code'] != null && m['qr_code'].toString().isNotEmpty;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(color: AppColors.primaryMuted, shape: BoxShape.circle),
                                    child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(m['name'] ?? 'Bank', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
                                        const SizedBox(height: 4),
                                        Text('${m['account_number'] ?? ''} a.n ${m['account_name'] ?? ''}', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (hasQr) ...[
                                const SizedBox(height: 16),
                                const Divider(color: AppColors.border),
                                const SizedBox(height: 12),
                                Center(
                                  child: Column(
                                    children: [
                                      Text('Scan QRIS di bawah ini:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                      const SizedBox(height: 12),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl: m['qr_code'],
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => const SizedBox(
                                            width: 200, height: 200,
                                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                          ),
                                          errorWidget: (context, url, error) => const SizedBox(
                                            width: 200, height: 200,
                                            child: Center(child: Icon(Icons.broken_image_rounded, size: 50, color: AppColors.textHint)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                  ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Gagal memuat metode pembayaran: $e'),
              ),
              const SizedBox(height: 40),

              Text('Upload Bukti Transfer', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              
              GestureDetector(
                onTap: _isUploading ? null : _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary, width: 1.5, style: BorderStyle.solid),
                  ),
                  child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_upload_rounded, size: 40, color: AppColors.primary),
                          const SizedBox(height: 12),
                          Text('Ketuk untuk memilih foto (JPG/PNG)', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14)),
                        ],
                      ),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _selectedImage == null || _isUploading ? null : _uploadProof,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isUploading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Konfirmasi Pembayaran'),
              ),
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/'),
                child: Text('Bayar Nanti (Lewati)', style: GoogleFonts.inter(color: AppColors.textHint)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
