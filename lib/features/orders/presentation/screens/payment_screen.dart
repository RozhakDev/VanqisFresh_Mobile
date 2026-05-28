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

/// Menampilkan layar pembayaran pesanan.
///
/// Halaman ini menampilkan daftar metode pembayaran yang tersedia
/// serta area untuk mengunggah bukti transfer pengguna.
class PaymentScreen extends ConsumerStatefulWidget {
  final String publicId;

  /// Membuat instance halaman pembayaran.
  ///
  /// Membutuhkan ID pesanan publik untuk memproses unggahan bukti.
  const PaymentScreen({super.key, required this.publicId});

  /// Menginisialisasi state yang mengatur interaksi pengguna.
  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

/// Menampilkan halaman untuk alur pengguna terkait.
///
/// Halaman ini mengatur tampilan dan interaksi utama fitur tersebut.
class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  File? _selectedImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  /// Membuka galeri perangkat untuk memilih gambar bukti transfer.
  ///
  /// Gambar yang dipilih akan disimpan di state lokal sebelum diunggah.
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.show(
        context,
        'Gagal memilih gambar. Periksa izin galeri lalu coba lagi.',
        type: SnackbarType.error,
      );
    }
  }

  /// Mengirim gambar bukti transfer ke server.
  ///
  /// Fungsi ini juga menangani proses pemuatan (*loading*) 
  /// serta navigasi otomatis ke halaman sukses jika unggahan berhasil.
  Future<void> _uploadProof() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    try {
      await ref.read(orderRepositoryProvider).uploadPaymentProof(widget.publicId, _selectedImage!.path);
      
      if (!mounted) return;
      context.go('/payment-success/${widget.publicId}');
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.show(context, e.toString().replaceAll('Exception: ', ''), type: SnackbarType.error);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  /// Menampilkan dialog berisi gambar yang bisa diperbesar (*zoomable*).
  ///
  /// Fitur ini sangat membantu pengguna saat perlu memindai kode QRIS
  /// secara detail dari layar perangkat mereka.
  void _showZoomableImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.cancel_rounded, color: Colors.white, size: 36),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: InteractiveViewer(
                panEnabled: true,
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
            ),
          ],
        ),
      ),
    );
  }

  /// Menentukan warna identitas berdasarkan nama metode pembayaran.
  ///
  /// Berguna untuk menampilkan logo bank atau *e-wallet* secara intuitif.
  Color _getPaymentColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('bca')) return const Color(0xFF0066AE);
    if (lower.contains('bri')) return const Color(0xFF00529C);
    if (lower.contains('mandiri')) return const Color(0xFFF2A123);
    if (lower.contains('bni')) return const Color(0xFF005E6A);
    if (lower.contains('gopay') || lower.contains('go-pay')) return const Color(0xFF00AED6);
    if (lower.contains('ovo')) return const Color(0xFF4C3494);
    if (lower.contains('dana')) return const Color(0xFF118EEA);
    if (lower.contains('shopeepay')) return const Color(0xFFEE4D2D);
    if (lower.contains('qris')) return const Color(0xFFED1C24);
    return AppColors.primary;
  }

  /// Mengembalikan ikon yang sesuai dengan jenis metode pembayaran.
  ///
  /// Menyesuaikan ikon otomatis antara QRIS, transfer bank, atau dompet digital.
  IconData _getPaymentIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('qris')) return Icons.qr_code_2_rounded;
    if (lower.contains('bank') || lower.contains('bca') || lower.contains('bri') || lower.contains('mandiri') || lower.contains('bni')) return Icons.account_balance_rounded;
    return Icons.account_balance_wallet_rounded;
  }

  /// Membangun antarmuka keseluruhan untuk layar pembayaran.
  ///
  /// Digunakan oleh Flutter untuk merender UI terbaru.
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
          onPressed: () => context.go('/'),
        ),
        title: Text(
          'Pembayaran',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: AppColors.textPrimary,
                size: 18,
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
              // Clean Success Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 36),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pesanan Berhasil Dibuat!',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.receipt_long_rounded, color: AppColors.textSecondary, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'ID: ${widget.publicId.split('-').first.toUpperCase()}',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text('Metode Pembayaran', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              
              paymentsAsync.when(
                data: (methods) => methods.isEmpty 
                  ? Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(child: Text('Belum ada metode pembayaran.', textAlign: TextAlign.center)),
                    )
                  : Column(
                      children: methods.map((m) {
                        final hasQr = m['qr_code'] != null && m['qr_code'].toString().isNotEmpty;
                        final String payName = m['name'] ?? 'Bank';
                        final Color pColor = _getPaymentColor(payName);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(color: AppColors.textPrimary.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: pColor.withOpacity(0.1), 
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(_getPaymentIcon(payName), color: pColor, size: 24),
                              ),
                              title: Text(payName, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text('${m['account_number'] ?? ''}', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                              ),
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text('Atas Nama', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textHint)),
                                      const SizedBox(height: 2),
                                      Text('${m['account_name'] ?? '-'}', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                      
                                      if (hasQr) ...[
                                        const SizedBox(height: 16),
                                        const Divider(color: AppColors.border),
                                        const SizedBox(height: 16),
                                        Text('Scan QRIS di bawah ini:', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                                        const SizedBox(height: 12),
                                        Center(
                                          child: GestureDetector(
                                            onTap: () => _showZoomableImage(context, m['qr_code']),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(color: AppColors.border),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                                                ],
                                              ),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(16),
                                                    child: CachedNetworkImage(
                                                      imageUrl: m['qr_code'],
                                                      width: 180,
                                                      height: 180,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                                                    child: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 20),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                  ),
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.error)),
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
                    color: _selectedImage != null ? AppColors.surface : AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
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
                                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                                child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
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
                            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), shape: BoxShape.circle),
                            child: const Icon(Icons.add_photo_alternate_rounded, size: 32, color: AppColors.primary),
                          ),
                          const SizedBox(height: 12),
                          Text('Ketuk untuk memilih foto', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('JPG atau PNG (Maks. 5MB)', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                ),
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _selectedImage == null || _isUploading ? null : _uploadProof,
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.border,
                  elevation: 0,
                ),
                child: _isUploading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Konfirmasi Pembayaran', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white)),
              ),
              
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/'),
                style: TextButton.styleFrom(
                  fixedSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Bayar Nanti (Lewati)', style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 14)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
