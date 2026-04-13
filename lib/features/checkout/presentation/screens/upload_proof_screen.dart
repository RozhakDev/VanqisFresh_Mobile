import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Bukti Transfer')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Selesaikan Pesanan Anda',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Order ID: ${widget.publicId.split('-').first.toUpperCase()}',
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
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
            const Spacer(),
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
}