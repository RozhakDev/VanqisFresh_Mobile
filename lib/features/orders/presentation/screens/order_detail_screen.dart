import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../catalog/presentation/widgets/product_image_placeholder.dart';
import '../../data/repositories/order_repository.dart';

final orderDetailProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, String>((ref, publicId) async {
  return ref.watch(orderRepositoryProvider).getOrderDetail(publicId);
});

class OrderDetailScreen extends ConsumerWidget {
  final String publicId;

  const OrderDetailScreen({super.key, required this.publicId});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.accentOrange;
      case 'confirmed':
      case 'preparing':
      case 'processing':
        return AppColors.accentBlue;
      case 'shipping':
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'preparing':
        return 'Disiapkan';
      case 'processing':
        return 'Diproses';
      case 'shipping':
        return 'Dikirim';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(orderDetailProvider(publicId));

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
          'Detail Pesanan',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          detailAsync.when(
            data: (_) => IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
              onPressed: () => ref.invalidate(orderDetailProvider(publicId)),
              tooltip: 'Muat Ulang',
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            ),
            error: (_, __) => IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
              onPressed: () => ref.invalidate(orderDetailProvider(publicId)),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: detailAsync.when(
        data: (order) {
          final items = order['items'] as List? ?? [];
          final status = order['status'] ?? 'Unknown';
          final paymentProof = order['payment_proof'];
          final isPending = status.toLowerCase() == 'pending';
          final needsUpload = isPending && (paymentProof == null || paymentProof == 'Belum diunggah');

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.refresh(orderDetailProvider(publicId).future),
                  color: AppColors.primary,
                  backgroundColor: Colors.white,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Container(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Status Pesanan', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _translateStatus(status),
                                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _getStatusColor(status)),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(color: AppColors.border, height: 1),
                            ),
                            _buildInfoRow('Waktu Pesanan', DateFormat('dd MMM yyyy, HH:mm').format(DateTime.tryParse(order['created_at'] ?? '') ?? DateTime.now())),
                            const SizedBox(height: 12),
                            _buildInfoRow('Order ID', publicId.split('-').first.toUpperCase()),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text('Identitas Penerima', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      Container(
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
                                const Icon(Icons.person_rounded, size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(order['customer_name'] ?? '-', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.phone_rounded, size: 16, color: AppColors.textHint),
                                const SizedBox(width: 8),
                                Text(order['customer_contact'] ?? '-', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on_rounded, size: 16, color: AppColors.textHint),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(order['shipping_address'] ?? '-', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                                ),
                              ],
                            ),
                            if (order['note'] != null && order['note'].toString().isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: AppColors.primaryMuted.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.note_alt_outlined, size: 16, color: AppColors.primaryDark),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text('Catatan: ${order['note']}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text('Rincian Pesanan', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: items.map((item) {
                            final price = item['price'] ?? 0;
                            final qty = item['quantity'] ?? 1;
                            final imageUrl = item['product_image'] ?? item['image'];
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52, 
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: AppColors.background, 
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.border)
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: imageUrl != null && imageUrl.toString().isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
                                            errorWidget: (context, url, error) => const ProductImagePlaceholder(iconSize: 24),
                                          )
                                        : const ProductImagePlaceholder(iconSize: 24, iconColor: AppColors.primaryDark),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['product_name'] ?? 'Item', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                                        const SizedBox(height: 2),
                                        Text('$qty x ${CurrencyFormat.convertToIdr(price)}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  Text(CurrencyFormat.convertToIdr(price * qty), style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppColors.primaryDark, fontSize: 14)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: AppColors.bottomBarShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Pembayaran', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                        Text(CurrencyFormat.convertToIdr(order['total_price'] ?? 0), style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                      ],
                    ),
                    if (needsUpload) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file_rounded, size: 20),
                          label: const Text('Upload Bukti Pembayaran'),
                          onPressed: () => context.push('/payment/$publicId'),
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 50, color: AppColors.error),
              const SizedBox(height: 16),
              Text(e.toString().replaceAll('Exception: ', ''), textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => ref.invalidate(orderDetailProvider), child: const Text('Coba Lagi')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
      ],
    );
  }
}