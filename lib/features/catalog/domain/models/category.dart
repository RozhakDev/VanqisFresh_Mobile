/// Merepresentasikan kategori produk yang tersedia.
///
/// Data ini dipakai untuk mengelompokkan produk katalog.
class Category {
  final int id;
  final String name;

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat Category perlu dibuat dengan nilai awal.
  Category({
    required this.id,
    required this.name,
  });

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat Category perlu dibuat dengan nilai awal.
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
