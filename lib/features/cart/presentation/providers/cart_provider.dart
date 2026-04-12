import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/cart_item.dart';
import '../../../catalog/domain/models/product.dart';

const _cartPrefsKey = 'vanqismart_cart';

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    _loadCart();
    return [];
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getStringList(_cartPrefsKey);
    if (cartJson != null) {
      state = cartJson.map((item) => CartItem.fromJson(item)).toList();
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartList = state.map((item) => item.toJson()).toList();
    await prefs.setStringList(_cartPrefsKey, cartList);
  }

  void addToCart(Product product) {
    if (!product.isAvailable || product.stock <= 0) return;

    final existingIndex = state.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      final currentItem = state[existingIndex];
      if (currentItem.quantity < product.stock) {
        state = [
          ...state.sublist(0, existingIndex),
          currentItem.copyWith(quantity: currentItem.quantity + 1),
          ...state.sublist(existingIndex + 1),
        ];
      }
    } else {
      state = [...state, CartItem(product: product, quantity: 1)];
    }
    _saveCart();
  }

  void removeFromCart(int productId) {
    state = state.where((item) => item.product.id != productId).toList();
    _saveCart();
  }

  void decrementQuantity(int productId) {
    final existingIndex = state.indexWhere((item) => item.product.id == productId);
    if (existingIndex >= 0) {
      final currentItem = state[existingIndex];
      if (currentItem.quantity > 1) {
        state = [
          ...state.sublist(0, existingIndex),
          currentItem.copyWith(quantity: currentItem.quantity - 1),
          ...state.sublist(existingIndex + 1),
        ];
      } else {
        removeFromCart(productId);
      }
      _saveCart();
    }
  }

  void clearCart() {
    state = [];
    _saveCart();
  }

  int get totalPrice {
    return state.fold(0, (total, item) => total + (item.product.price * item.quantity));
  }

  int get totalItems {
    return state.fold(0, (total, item) => total + item.quantity);
  }
}