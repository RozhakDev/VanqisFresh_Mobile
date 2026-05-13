/// Merepresentasikan data produk yang dijual aplikasi.
///
/// Model ini digunakan pada katalog, detail, dan keranjang.
class Product {
  final int id;
  final String name;
  final int categoryId;
  final String categoryName;
  final int price;
  final String unit;
  final String description;
  final String image;
  final int stock;
  final bool isAvailable;

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat Product perlu dibuat dengan nilai awal.
  Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    required this.unit,
    required this.description,
    required this.image,
    required this.stock,
    required this.isAvailable,
  });

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat Product perlu dibuat dengan nilai awal.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      categoryId: json['category'] as int,
      categoryName: json['category_name'] as String,
      price: json['price'] as int,
      unit: json['unit'] as String? ?? 'satuan',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      stock: json['stock'] as int,
      isAvailable: json['is_available'] as bool? ?? false,
    );
  }
}

/// Merepresentasikan respons daftar produk yang memiliki paginasi.
///
/// Data ini membantu memuat produk secara bertahap.
class ProductPaginatedResponse {
  final int count;
  final String? nextUrl;
  final List<Product> results;

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat ProductPaginatedResponse perlu dibuat dengan nilai awal.
  ProductPaginatedResponse({
    required this.count,
    this.nextUrl,
    required this.results,
  });

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat ProductPaginatedResponse perlu dibuat dengan nilai awal.
  factory ProductPaginatedResponse.fromJson(Map<String, dynamic> json) {
    return ProductPaginatedResponse(
      count: json['count'] as int? ?? 0,
      nextUrl: json['next'] as String?,
      results: (json['results'] as List<dynamic>?)
              ?.map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
