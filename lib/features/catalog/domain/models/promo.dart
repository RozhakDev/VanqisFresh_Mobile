import 'product.dart';

class Promo {
  final int id;
  final String title;
  final String description;
  final List<Product> products;
  final bool isActive;

  Promo({
    required this.id,
    required this.title,
    required this.description,
    required this.products,
    required this.isActive,
  });

  factory Promo.fromJson(Map<String, dynamic> json) {
    return Promo(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] ?? '',
      products: (json['products'] as List<dynamic>?)
              ?.map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}