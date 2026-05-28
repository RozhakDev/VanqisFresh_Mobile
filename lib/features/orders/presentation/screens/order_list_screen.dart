import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/main_bottom_nav_bar.dart';
import '../../data/repositories/order_repository.dart';

/// Menyimpan state yang dibutuhkan fitur terkait.
///
/// Data ini dipakai untuk menentukan tampilan dan proses fitur.
class OrderPaginationState {
  final List<dynamic> orders;
  final bool isLoading;
  final String? nextUrl;
  final String? error;

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat OrderPaginationState perlu dibuat dengan nilai awal.
  OrderPaginationState({
    this.orders = const [],
    this.isLoading = false,
    this.nextUrl,
    this.error,
  });

  /// Membuat salinan data dengan nilai yang dapat diperbarui.
  ///
  /// Membantu menjaga perubahan state tetap aman dan terarah.
  OrderPaginationState copyWith({
    List<dynamic>? orders,
    bool? isLoading,
    String? nextUrl,
    String? error,
  }) {
    return OrderPaginationState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      nextUrl: nextUrl ?? this.nextUrl,
      error: error,
    );
  }
}

/// Mengelola state dan aksi untuk fitur terkait.
///
/// Notifier ini memperbarui state berdasarkan interaksi atau hasil request.
class OrderPaginationNotifier extends Notifier<OrderPaginationState> {
  /// Membangun tampilan berdasarkan context dan state saat ini.
  ///
  /// Digunakan oleh Flutter untuk merender UI terbaru.
  @override
  OrderPaginationState build() {
    Future.microtask(() => fetchInitial());
    return OrderPaginationState();
  }

  /// Memuat daftar awal untuk ditampilkan.
  ///
  /// Dipakai saat halaman pertama kali membutuhkan data.
  Future<void> fetchInitial() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await ref.read(orderRepositoryProvider).getOrders();
      final results = response['results'] as List? ?? [];
      final next = response['next'] as String?;

      state = OrderPaginationState(
        orders: results,
        isLoading: false,
        nextUrl: next,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Memuat halaman berikutnya saat data masih tersedia.
  ///
  /// Digunakan untuk mendukung paginasi saat pengguna menggulir.
  Future<void> fetchNextPage() async {
    if (state.isLoading || state.nextUrl == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final response = await ref.read(orderRepositoryProvider).getOrders(nextUrl: state.nextUrl);
      final results = response['results'] as List? ?? [];
      final next = response['next'] as String?;

      state = OrderPaginationState(
        orders: [...state.orders, ...results],
        isLoading: false,
        nextUrl: next,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final ordersProvider = NotifierProvider<OrderPaginationNotifier, OrderPaginationState>(() {
  return OrderPaginationNotifier();
});

/// Menampilkan halaman untuk alur pengguna terkait.
///
/// Halaman ini mengatur tampilan dan interaksi utama fitur tersebut.
class OrderListScreen extends ConsumerStatefulWidget {
  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat OrderListScreen perlu dibuat dengan nilai awal.
  const OrderListScreen({super.key});

  /// Membuat state yang mengelola perilaku widget.
  ///
  /// State ini menyimpan interaksi dan perubahan lokal widget.
  @override
  ConsumerState<OrderListScreen> createState() => _OrderListScreenState();
}

/// Menampilkan halaman untuk alur pengguna terkait.
///
/// Halaman ini mengatur tampilan dan interaksi utama fitur tersebut.
class _OrderListScreenState extends ConsumerState<OrderListScreen> {
  final ScrollController _scrollController = ScrollController();

  /// Menyiapkan state awal saat widget dibuat.
  ///
  /// Digunakan untuk inisialisasi sebelum tampilan pertama dirender.
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  /// Membersihkan resource saat widget tidak lagi digunakan.
  ///
  /// Dipanggil untuk melepas controller, listener, atau timer.
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Menangani aksi pengguna saat menggulir daftar.
  ///
  /// Digunakan untuk memicu pemuatan data berikutnya.
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(ordersProvider.notifier).fetchNextPage();
    }
  }

  /// Menentukan warna yang sesuai dengan status pesanan.
  ///
  /// Warna membantu pengguna mengenali kondisi pesanan.
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

  /// Menerjemahkan status pesanan ke teks yang mudah dipahami.
  ///
  /// Dipakai agar label status lebih ramah untuk pengguna.
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

  /// Mengelola build body pada fitur terkait.
  ///
  /// Digunakan untuk menjaga alur fitur tetap jelas dan terstruktur.
  Widget _buildBody(OrderPaginationState orderState) {
    if (orderState.error != null && orderState.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Pesanan',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              orderState.error!.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(ordersProvider.notifier).fetchInitial(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Coba Lagi',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (orderState.isLoading && orderState.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final results = orderState.orders;

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_rounded, size: 80, color: AppColors.textHint),
            const SizedBox(height: 24),
            Text('Belum Ada Pesanan', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Ayo mulai belanja dan penuhi kulkasmu!', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text('Mulai Belanja'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: Colors.white,
      onRefresh: () => ref.read(ordersProvider.notifier).fetchInitial(),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: results.length + (orderState.nextUrl != null ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == results.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

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
                          color: _getStatusColor(status).withValues(alpha: 0.12),
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
                        child: const Icon(Icons.shopping_cart_outlined, color: AppColors.primaryDark, size: 24),
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
  }

  /// Membangun tampilan berdasarkan context dan state saat ini.
  ///
  /// Digunakan oleh Flutter untuk merender UI terbaru.
  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Pesanan Saya',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          if (orderState.isLoading && orderState.orders.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
              onPressed: () => ref.read(ordersProvider.notifier).fetchInitial(),
              tooltip: 'Muat Ulang',
            ),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: MainBottomNavBar(currentIndex: 1),
      body: _buildBody(orderState),
    );
  }
}
