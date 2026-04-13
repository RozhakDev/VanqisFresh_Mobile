import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/models/order_models.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(dioProvider));
});

class OrderRepository {
  final Dio _dio;
  OrderRepository(this._dio);

  Future<OrderDetail> getOrderDetail(String publicId, String token) async {
    try {
      final response = await _dio.get(
        '/orders/$publicId/',
        options: Options(headers: {'X-Order-Token': token}),
      );
      return OrderDetail.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}