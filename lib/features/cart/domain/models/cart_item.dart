import 'dart:convert';
import '../../../catalog/domain/models/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product': {
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'image': product.image,
        'stock': product.stock,
        'category': product.categoryId,
        'category_name': product.categoryName,
      },
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: Product.fromJson(map['product']),
      quantity: map['quantity']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());
  factory CartItem.fromJson(String source) => CartItem.fromMap(json.decode(source));
}