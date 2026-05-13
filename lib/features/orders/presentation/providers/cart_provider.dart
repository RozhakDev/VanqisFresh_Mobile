import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/cart_item.dart';
import '../../../catalog/domain/models/product.dart';

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});

/// Mengelola state dan aksi untuk fitur terkait.
///
/// Notifier ini memperbarui state berdasarkan interaksi atau hasil request.
class CartNotifier extends Notifier<List<CartItem>> {
  /// Membangun tampilan berdasarkan context dan state saat ini.
  ///
  /// Digunakan oleh Flutter untuk merender UI terbaru.
  @override
  List<CartItem> build() {
    return [];
  }

  /// Menambahkan produk ke keranjang atau memperbarui jumlahnya.
  ///
  /// Dipakai saat pengguna memilih produk untuk dibeli.
  void addItem(Product product, int quantity) {
    final stateList = state.toList();
    final index = stateList.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      final existing = stateList[index];
      final newQty = (existing.quantity + quantity).clamp(1, product.stock);
      stateList[index] = existing.copyWith(quantity: newQty);
    } else {
      stateList.add(CartItem(product: product, quantity: quantity.clamp(1, product.stock)));
    }
    state = stateList;
  }

  /// Memperbarui jumlah produk di keranjang.
  ///
  /// Perubahan ini menjaga total belanja tetap sesuai pilihan pengguna.
  void updateQuantity(int productId, int quantity) {
    if (quantity < 1) {
      removeItem(productId);
      return;
    }
    state = state.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity.clamp(1, item.product.stock));
      }
      return item;
    }).toList();
  }

  /// Menghapus produk dari keranjang.
  ///
  /// Digunakan saat pengguna tidak ingin membeli item tersebut.
  void removeItem(int productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  /// Mengosongkan seluruh item dari keranjang.
  ///
  /// Digunakan setelah checkout selesai atau keranjang direset.
  void clearCart() {
    state = [];
  }

  int get totalPrice {
    return state.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }
}
