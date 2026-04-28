import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/cart_item.dart';
import '../../../catalog/domain/models/product.dart';

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    return [];
  }

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

  void removeItem(int productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void clearCart() {
    state = [];
  }

  int get totalPrice {
    return state.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }
}
