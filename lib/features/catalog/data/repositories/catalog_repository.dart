import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/models/category.dart';
import '../../domain/models/product.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CatalogRepository(dio);
});

class CatalogRepository {
  final Dio _dio;

  CatalogRepository(this._dio);

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

  Future<ProductPaginatedResponse> getProducts({
    int page = 1,
    String? search,
    int? categoryId,
  }) async {
    try {
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
}