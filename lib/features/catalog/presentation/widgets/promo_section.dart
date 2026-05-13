import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/catalog_provider.dart';
import 'product_card.dart';

/// Menampilkan komponen UI untuk kebutuhan halaman terkait.
///
/// Komponen ini membantu menyusun tampilan agar konsisten dan mudah digunakan.
class PromoSection extends ConsumerWidget {
  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat PromoSection perlu dibuat dengan nilai awal.
  const PromoSection({super.key});

  /// Membangun tampilan berdasarkan context dan state saat ini.
  ///
  /// Digunakan oleh Flutter untuk merender UI terbaru.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promosAsync = ref.watch(promosProvider);

    return promosAsync.when(
      data: (promos) {
        final activePromos = promos.where((p) => p.isActive && p.products.isNotEmpty).toList();
        
        if (activePromos.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final promo = activePromos[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.symmetric(vertical: 16),
                color: AppColors.primary.withOpacity(0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.local_offer, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              promo.title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (promo.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          promo.description,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 260,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: promo.products.length,
                        itemBuilder: (context, pIndex) {
                          final product = promo.products[pIndex];
                          return Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: 16),
                            child: ProductCard(product: product),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
            childCount: activePromos.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
      ),
      error: (error, stack) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }
}
