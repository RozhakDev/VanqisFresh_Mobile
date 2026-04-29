import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(orderDetailProvider(publicId));

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
          'Detail Pesanan',
          style: GoogleFonts.inter(color: AppColors.textOnPrimary, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
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
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Header Info
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
                              Text('Status', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: _getStatusColor(status)),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24, color: AppColors.border),
                          _buildInfoRow('Waktu Pesanan', DateFormat('dd MMM yyyy, HH:mm').format(DateTime.tryParse(order['created_at'] ?? '') ?? DateTime.now())),
                          const SizedBox(height: 12),
                          _buildInfoRow('Order ID', publicId.split('-').first.toUpperCase()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text('Informasi Pengiriman', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
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
                          Text(order['customer_name'] ?? '-', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(order['customer_contact'] ?? '-', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Text(order['shipping_address'] ?? '-', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                          if (order['note'] != null && order['note'].toString().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.primaryMuted.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.note_alt_outlined, size: 16, color: AppColors.textSecondary),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text('Catatan: ${order['note']}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary))),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text('Daftar Belanja', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
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
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.eco_rounded, color: AppColors.primaryMuted, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['product_name'] ?? 'Item', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                                      Text('$qty x ${CurrencyFormat.convertToIdr(price)}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                Text(CurrencyFormat.convertToIdr(price * qty), style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
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
                        Text('Total Pembayaran', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 50, color: AppColors.error),
              const SizedBox(height: 16),
              Text(e.toString().replaceAll('Exception: ', ''), textAlign: TextAlign.center),
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
        Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
      ],
    );
  }
}
