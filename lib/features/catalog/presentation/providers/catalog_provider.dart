import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/repositories/catalog_repository.dart';
import '../../domain/models/category.dart';
import '../../domain/models/product.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.getCategories();
});

class ProductPaginationState {
  final List<Product> products;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;

  ProductPaginationState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
  });

  ProductPaginationState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return ProductPaginationState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

final productsProvider = StateNotifierProvider<ProductNotifier, ProductPaginationState>((ref) {
  final repo = ref.watch(catalogRepositoryProvider);
  return ProductNotifier(repo);
});

class ProductNotifier extends StateNotifier<ProductPaginationState> {
  final CatalogRepository _repository;
  String? _currentSearch;
  int? _currentCategoryId;

  ProductNotifier(this._repository) : super(ProductPaginationState()) {
    fetchInitialProducts();
  }

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

      state = state.copyWith(
        products: response.results,
        isLoading: false,
        currentPage: 1,
        hasMore: response.currentPage < response.totalPages,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}