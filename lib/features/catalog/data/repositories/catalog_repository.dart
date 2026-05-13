import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/models/category.dart';
import '../../domain/models/product.dart';
import '../../domain/models/promo.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CatalogRepository(dio);
});

/// Mengelola akses data dan komunikasi dengan layanan terkait.
///
/// Class ini menjadi penghubung antara fitur dan sumber data.
class CatalogRepository {
  final Dio _dio;

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat CatalogRepository perlu dibuat dengan nilai awal.
  CatalogRepository(this._dio);

  /// Mengambil daftar kategori dari server.
  ///
  /// Data ini digunakan untuk filter produk di katalog.
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/catalog/categories/');
      final data = response.data as List;
      return data.map((json) => Category.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Mengambil daftar produk dengan filter yang tersedia.
  ///
  /// Mendukung pencarian, kategori, dan paginasi katalog.
  Future<ProductPaginatedResponse> getProducts({
    String? nextUrl,
    int page = 1,
    String? search,
    int? categoryId,
  }) async {
    try {
      if (nextUrl != null) {
        final response = await _dio.get(nextUrl);
        return ProductPaginatedResponse.fromJson(response.data);
      }

      final Map<String, dynamic> queryParams = {'page': page};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (categoryId != null) queryParams['category'] = categoryId;
      queryParams['is_available'] = true;

      final response = await _dio.get('/catalog/products/', queryParameters: queryParams);
      return ProductPaginatedResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Mengambil daftar promo aktif dari server.
  ///
  /// Promo ditampilkan pada bagian penawaran di katalog.
  Future<List<Promo>> getPromos() async {
    try {
      final response = await _dio.get('/catalog/promos/');
      final data = response.data as List;
      return data.map((json) => Promo.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Mengambil detail produk berdasarkan ID.
  ///
  /// Data detail dipakai pada halaman produk.
  Future<Product> getProductDetail(int id) async {
    try {
      final response = await _dio.get('/catalog/products/$id/');
      return Product.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
