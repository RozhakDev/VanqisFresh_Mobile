import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';
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
      SnackbarUtils.show(context, 'Pembayaran berhasil dikonfirmasi!', type: SnackbarType.success);
      
      context.go('/');
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.show(context, e.toString().replaceAll('Exception: ', ''), type: SnackbarType.error);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showZoomableImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    color: Colors.white,
                    width: 300,
                    height: 300,
                    child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.white,
                    width: 300,
                    height: 300,
                    child: const Center(child: Icon(Icons.broken_image_rounded, size: 50, color: AppColors.textHint)),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30, shadows: [Shadow(color: Colors.black54, blurRadius: 4)]),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(paymentMethodsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Pembayaran',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text('Pesanan Berhasil Dibuat!', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryDark), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('ID: ${widget.publicId}', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 32),

              Text('Pilih Metode Pembayaran', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              
              paymentsAsync.when(
                data: (methods) => methods.isEmpty 
                  ? Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(child: Text('Belum ada metode pembayaran yang dikonfigurasi admin.', textAlign: TextAlign.center)),
                    )
                  : Column(
                      children: methods.map((m) {
                        final hasQr = m['qr_code'] != null && m['qr_code'].toString().isNotEmpty;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryMuted.withOpacity(0.4), 
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(m['name'] ?? 'Bank', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
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
                                const SizedBox(height: 16),
                                Center(
                                  child: Column(
                                    children: [
                                      Text('Scan QRIS di bawah ini:', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                      const SizedBox(height: 12),
                                      GestureDetector(
                                        onTap: () => _showZoomableImage(context, m['qr_code']),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(color: AppColors.border),
                                                color: Colors.white,
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(16),
                                                child: CachedNetworkImage(
                                                  imageUrl: m['qr_code'],
                                                  width: 220,
                                                  height: 220,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) => const SizedBox(
                                                    width: 220, height: 220,
                                                    child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                                                  ),
                                                  errorWidget: (context, url, error) => const SizedBox(
                                                    width: 220, height: 220,
                                                    child: Center(child: Icon(Icons.broken_image_rounded, size: 50, color: AppColors.textHint)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.5),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 24),
                                            ),
                                          ],
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
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Text('Gagal memuat metode pembayaran: $e', style: GoogleFonts.inter(color: AppColors.error)),
                ),
              ),
              const SizedBox(height: 32),

              Text('Upload Bukti Transfer', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              
              GestureDetector(
                onTap: _isUploading ? null : _pickImage,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5, style: BorderStyle.solid),
                  ),
                  child: _selectedImage != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(_selectedImage!, fit: BoxFit.cover),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedImage = null),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                              ),
                            ),
                          )
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryMuted.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.cloud_upload_rounded, size: 32, color: AppColors.primary),
                          ),
                          const SizedBox(height: 12),
                          Text('Ketuk untuk memilih foto', style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Format yang didukung: JPG/PNG', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                ),
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _selectedImage == null || _isUploading ? null : _uploadProof,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.border,
                ),
                child: _isUploading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Konfirmasi Pembayaran', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white)),
              ),
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Bayar Nanti (Lewati)', style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 15)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}