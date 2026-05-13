import 'product.dart';

/// Merepresentasikan data promo yang ditampilkan aplikasi.
///
/// Promo digunakan pada banner dan daftar produk promo.
class Promo {
  final int id;
  final String title;
  final String description;
  final List<Product> products;
  final bool isActive;

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat Promo perlu dibuat dengan nilai awal.
  Promo({
    required this.id,
    required this.title,
    required this.description,
    required this.products,
    required this.isActive,
  });

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat Promo perlu dibuat dengan nilai awal.
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
