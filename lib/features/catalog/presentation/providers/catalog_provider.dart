import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/catalog_repository.dart';
import '../../domain/models/category.dart';
import '../../domain/models/product.dart';
import '../../domain/models/promo.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return ref.watch(catalogRepositoryProvider).getCategories();
});

final promosProvider = FutureProvider<List<Promo>>((ref) async {
  return ref.watch(catalogRepositoryProvider).getPromos();
});

final productDetailProvider = FutureProvider.family<Product, int>((ref, productId) async {
  return ref.watch(catalogRepositoryProvider).getProductDetail(productId);
});

/// Menyimpan state yang dibutuhkan fitur terkait.
///
/// Data ini dipakai untuk menentukan tampilan dan proses fitur.
class ProductPaginationState {
  final List<Product> products;
  final bool isLoading;
  final String? error;
  final String? nextUrl;

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat ProductPaginationState perlu dibuat dengan nilai awal.
  ProductPaginationState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.nextUrl,
  });

  /// Membuat salinan data dengan nilai yang dapat diperbarui.
  ///
  /// Membantu menjaga perubahan state tetap aman dan terarah.
  ProductPaginationState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
    String? nextUrl,
  }) {
    return ProductPaginationState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      nextUrl: nextUrl ?? this.nextUrl,
    );
  }
}

final productsProvider = NotifierProvider<ProductNotifier, ProductPaginationState>(() {
  return ProductNotifier();
});

/// Mengelola state dan aksi untuk fitur terkait.
///
/// Notifier ini memperbarui state berdasarkan interaksi atau hasil request.
class ProductNotifier extends Notifier<ProductPaginationState> {
  late CatalogRepository _repository;
  String? _currentSearch;
  int? _currentCategoryId;

  /// Membangun tampilan berdasarkan context dan state saat ini.
  ///
  /// Digunakan oleh Flutter untuk merender UI terbaru.
  @override
  ProductPaginationState build() {
    _repository = ref.watch(catalogRepositoryProvider);
    Future.microtask(() => fetchInitialProducts());
    return ProductPaginationState();
  }

  /// Memuat daftar produk awal berdasarkan filter aktif.
  ///
  /// Dipakai saat katalog pertama kali dibuka atau filter berubah.
  Future<void> fetchInitialProducts({String? search, int? categoryId}) async {
    _currentSearch = search;
    _currentCategoryId = categoryId;
    state = ProductPaginationState(isLoading: true);

    try {
      final response = await _repository.getProducts(
        page: 1,
        search: _currentSearch,
        categoryId: _currentCategoryId,
      );

      state = ProductPaginationState(
        products: response.results,
        isLoading: false,
        nextUrl: response.nextUrl,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Memuat halaman berikutnya saat data masih tersedia.
  ///
  /// Digunakan untuk mendukung paginasi saat pengguna menggulir.
  Future<void> fetchNextPage() async {
    if (state.isLoading || state.nextUrl == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final response = await _repository.getProducts(
        nextUrl: state.nextUrl,
      );

      state = ProductPaginationState(
        products: [...state.products, ...response.results],
        isLoading: false,
        nextUrl: response.nextUrl,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
