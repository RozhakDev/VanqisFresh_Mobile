import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final totalPrice = cartNotifier.totalPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                _showClearCartDialog(context, cartNotifier);
              },
              child: const Text('Hapus Semua', style: TextStyle(color: AppColors.error)),
            )
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_basket_outlined, size: 100, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('Keranjang Anda masih kosong', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Mulai Belanja'),
                  )
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              separatorBuilder: (context, index) => const Divider(height: 32),
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: item.product.image,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) => Container(color: Colors.grey[200], child: const Icon(Icons.image)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormat.convertToIdr(item.product.price),
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => cartNotifier.decrementQuantity(item.product.id),
                          icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                        ),
                        Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(
                          onPressed: item.quantity < item.product.stock
                              ? () => cartNotifier.addToCart(item.product)
                              : null,
                          icon: Icon(
                            Icons.add_circle_outline,
                            color: item.quantity < item.product.stock ? AppColors.primary : Colors.grey,
                          ),
                        ),
                      ],
                    )
                  ],
                );
              },
            ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Pembayaran', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        Text(
                          CurrencyFormat.convertToIdr(totalPrice),
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                      onPressed: () => context.push('/checkout'),
                      child: const Text('Checkout'),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Keranjang?'),
        content: const Text('Semua produk di keranjang akan dihapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              notifier.clearCart();
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}