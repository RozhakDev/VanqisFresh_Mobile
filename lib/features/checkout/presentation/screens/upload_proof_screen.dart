import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/models/payment_method.dart';
import '../providers/checkout_provider.dart';

class UploadProofScreen extends ConsumerStatefulWidget {
  final String publicId;
  const UploadProofScreen({super.key, required this.publicId});

  @override
  ConsumerState<UploadProofScreen> createState() => _UploadProofScreenState();
}

class _UploadProofScreenState extends ConsumerState<UploadProofScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70); // Kompres gambar agar < 5MB
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submitProof() async {
    if (_imageFile == null) return;
    
    final success = await ref.read(checkoutNotifierProvider.notifier).uploadProof(_imageFile!);
    
    if (success && mounted) {
      ref.read(cartProvider.notifier).clearCart();
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: AppColors.primary, size: 64),
          title: const Text('Pesanan Berhasil!'),
          content: const Text('Bukti pembayaran sedang diverifikasi admin. Terima kasih!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/');
              },
              child: const Text('Selesai'),
            )
          ],
        ),
      );
    } else if (mounted) {
      final error = ref.read(checkoutNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Gagal upload'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(checkoutNotifierProvider).isLoading;
    final paymentMethodsAsync = ref.watch(paymentMethodsProvider);
    final orderResponse = ref.watch(checkoutNotifierProvider).orderResponse;

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran Transfer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Selesaikan Pembayaran Anda',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Order ID: ${widget.publicId.split('-').first.toUpperCase()}',
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (orderResponse != null) ...[
              const SizedBox(height: 8),
              Text(
                'Total Tagihan: ${CurrencyFormat.convertToIdr(orderResponse.totalPrice)}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Pilih metode pembayaran yang tersedia lalu lakukan transfer di luar aplikasi.',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            paymentMethodsAsync.when(
              data: (paymentMethods) {
                if (paymentMethods.isEmpty) {
                  return _buildPaymentNotice(
                    icon: Icons.info_outline,
                    title: 'Metode pembayaran belum tersedia',
                    message:
                        'Admin belum mengaktifkan metode pembayaran. Coba lagi beberapa saat.',
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: paymentMethods
                      .map((method) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _PaymentMethodCard(method: method),
                          ))
                      .toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => _buildPaymentNotice(
                icon: Icons.error_outline,
                title: 'Gagal memuat metode pembayaran',
                message: error.toString(),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Upload Bukti Transfer',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: isLoading ? null : _pickImage,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('Tap untuk pilih gambar dari Galeri', style: TextStyle(color: Colors.grey)),
                          Text('(Maks. 5MB, format JPG/PNG)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: (_imageFile == null || isLoading) ? null : _submitProof,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Konfirmasi & Kirim Bukti', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentNotice({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;

  const _PaymentMethodCard({required this.method});

  @override
  Widget build(BuildContext context) {
    final hasQrCode = method.qrCode != null && method.qrCode!.isNotEmpty;
    final accountNumber = method.accountNumber?.trim();
    final accountName = method.accountName?.trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconForMethod(method.providerType),
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _labelForProviderType(method.providerType),
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (accountName != null && accountName.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Atas Nama: $accountName',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
          if (accountNumber != null && accountNumber.isNotEmpty) ...[
            const SizedBox(height: 8),
            SelectableText(
              accountNumber,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          if (hasQrCode) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: method.qrCode!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 220,
                  color: Colors.grey[100],
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 220,
                  color: Colors.grey[100],
                  alignment: Alignment.center,
                  child: const Text(
                    'QR code gagal dimuat',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static IconData _iconForMethod(String providerType) {
    switch (providerType.toLowerCase()) {
      case 'bank':
        return Icons.account_balance_outlined;
      case 'e-wallet':
        return Icons.account_balance_wallet_outlined;
      case 'qris':
        return Icons.qr_code_2_outlined;
      default:
        return Icons.payments_outlined;
    }
  }

  static String _labelForProviderType(String providerType) {
    switch (providerType.toLowerCase()) {
      case 'bank':
        return 'Transfer Bank';
      case 'e-wallet':
        return 'E-Wallet';
      case 'qris':
        return 'QRIS';
      default:
        return providerType;
    }
  }
}