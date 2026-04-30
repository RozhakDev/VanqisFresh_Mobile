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
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Riwayat Pesanan',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          ordersAsync.when(
            data: (_) => IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
              onPressed: () => ref.invalidate(ordersProvider),
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
              onPressed: () => ref.invalidate(ordersProvider),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go('/');
          if (index == 2) context.go('/checkout');
          if (index == 3) context.go('/profile');
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500),
        elevation: 20,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Keranjang'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
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
                            Row(
                              children: [
                                const Icon(Icons.schedule_rounded, size: 14, color: AppColors.textHint),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('dd MMM yyyy, HH:mm').format(createdAt),
                                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
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
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: AppColors.border, height: 1),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.background, 
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Order ID', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textHint)),
                                  const SizedBox(height: 2),
                                  Text(
                                    publicId.split('-').first.toUpperCase(),
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Total Belanja', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textHint)),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormat.convertToIdr(totalPrice),
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primaryDark),
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