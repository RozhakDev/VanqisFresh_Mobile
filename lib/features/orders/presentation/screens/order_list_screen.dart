import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/repositories/order_repository.dart';

final ordersProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.watch(orderRepositoryProvider).getOrders();
});

class OrderListScreen extends ConsumerWidget {
  const OrderListScreen({super.key});

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
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textOnPrimary),
          onPressed: () => context.go('/'),
        ),
        title: Text(
          'Riwayat Pesanan',
          style: GoogleFonts.inter(color: AppColors.textOnPrimary, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ordersAsync.when(
        data: (data) {
          final results = data['results'] as List? ?? [];

          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_rounded, size: 80, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('Belum ada pesanan', style: GoogleFonts.inter(fontSize: 18, color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(ordersProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: results.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final order = results[index];
                final String publicId = order['public_id'];
                final String status = order['status'] ?? 'Unknown';
                final int totalPrice = order['total_price'] ?? 0;
                final DateTime createdAt = DateTime.tryParse(order['created_at'] ?? '') ?? DateTime.now();

                return InkWell(
                  onTap: () => context.push('/orders/$publicId'),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
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
                            Text(
                              DateFormat('dd MMM yyyy, HH:mm').format(createdAt),
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                status,
                                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: _getStatusColor(status)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.shopping_bag_rounded, color: AppColors.primaryMuted),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Order ID', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textHint)),
                                  Text(
                                    publicId.split('-').first.toUpperCase(),
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Total', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textHint)),
                                Text(
                                  CurrencyFormat.convertToIdr(totalPrice),
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
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
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => ref.invalidate(ordersProvider), child: const Text('Coba Lagi')),
            ],
          ),
        ),
      ),
    );
  }
}
