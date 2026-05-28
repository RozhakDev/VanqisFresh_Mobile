import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../orders/presentation/providers/cart_provider.dart';
import '../../domain/models/product.dart';
import '../../domain/models/promo.dart';
import 'product_image_placeholder.dart';

/// Merepresentasikan data utama yang digunakan pada fitur terkait.
///
/// Model ini membantu menjaga struktur data tetap jelas.
class PromoProductsSheet extends ConsumerWidget {
  final Promo promo;
  final BuildContext hostContext;

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat PromoProductsSheet perlu dibuat dengan nilai awal.
  const PromoProductsSheet({
    super.key,
    required this.promo,
    required this.hostContext,
  });

  /// Menampilkan komponen sesuai konteks yang diberikan.
  ///
  /// Dipakai saat UI perlu dibuka dari lokasi lain.
  static Future<void> show(BuildContext context, Promo promo) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => PromoProductsSheet(promo: promo, hostContext: context),
    );
  }

  /// Membangun tampilan berdasarkan context dan state saat ini.
  ///
  /// Digunakan oleh Flutter untuk merender UI terbaru.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableProducts = promo.products
        .where((product) => product.isAvailable && product.stock > 0)
        .toList();
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.48,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryMuted,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.local_offer_rounded,
                            color: AppColors.primaryDark,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                promo.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                  height: 1.2,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (promo.description.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  promo.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${availableProducts.length} produk tersedia dalam promo ini',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: availableProducts.isEmpty
                    ? const _PromoEmptyState()
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        itemCount: availableProducts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final product = availableProducts[index];
                          return _PromoProductTile(
                            product: product,
                            hostContext: hostContext,
                          );
                        },
                      ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 14, 20, bottomPadding + 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: AppColors.bottomBarShadow,
                  border: const Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: availableProducts.isEmpty
                        ? null
                        : () {
                            for (final product in availableProducts) {
                              ref.read(cartProvider.notifier).addItem(product, 1);
                            }
                            Navigator.of(context).pop();
                            SnackbarUtils.show(
                              hostContext,
                              'Semua produk promo masuk keranjang.',
                              type: SnackbarType.success,
                              action: SnackBarAction(
                                label: 'CHECKOUT',
                                onPressed: () => hostContext.push('/checkout'),
                              ),
                            );
                          },
                    icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 18),
                    label: Text(
                      'Tambah Semua ke Keranjang',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Menampilkan komponen UI untuk kebutuhan halaman terkait.
///
/// Komponen ini membantu menyusun tampilan agar konsisten dan mudah digunakan.
class _PromoProductTile extends ConsumerWidget {
  final Product product;
  final BuildContext hostContext;

  const _PromoProductTile({
    required this.product,
    required this.hostContext,
  });

  /// Membangun tampilan berdasarkan context dan state saat ini.
  ///
  /// Digunakan oleh Flutter untuk merender UI terbaru.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: product.image.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.image,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => const ProductImagePlaceholder(),
                  )
                : const ProductImagePlaceholder(iconColor: AppColors.primaryDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      CurrencyFormat.convertToIdr(product.price),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/ ${product.unit}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filled(
            onPressed: () {
              ref.read(cartProvider.notifier).addItem(product, 1);
              SnackbarUtils.show(
                hostContext,
                '${product.name} masuk keranjang.',
                type: SnackbarType.success,
              );
            },
            icon: const Icon(Icons.add_rounded, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              fixedSize: const Size(36, 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Menyimpan state yang dibutuhkan fitur terkait.
///
/// Data ini dipakai untuk menentukan tampilan dan proses fitur.
class _PromoEmptyState extends StatelessWidget {
  const _PromoEmptyState();

  /// Membangun tampilan berdasarkan context dan state saat ini.
  ///
  /// Digunakan oleh Flutter untuk merender UI terbaru.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primaryMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_offer_outlined,
                color: AppColors.primaryDark,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Produk promo belum tersedia',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Cek kembali nanti untuk pilihan sayur dan buah segar lainnya.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
