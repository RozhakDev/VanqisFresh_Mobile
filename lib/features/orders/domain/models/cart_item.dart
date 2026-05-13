import '../../../catalog/domain/models/product.dart';

/// Merepresentasikan produk dan jumlahnya di keranjang.
///
/// Model ini dipakai untuk menghitung item checkout.
class CartItem {
  final Product product;
  final int quantity;

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat CartItem perlu dibuat dengan nilai awal.
  CartItem({required this.product, required this.quantity});

  /// Membuat salinan data dengan nilai yang dapat diperbarui.
  ///
  /// Membantu menjaga perubahan state tetap aman dan terarah.
  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
