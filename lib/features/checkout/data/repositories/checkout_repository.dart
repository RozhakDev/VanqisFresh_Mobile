import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/models/checkout_models.dart';
import '../../domain/models/payment_method.dart';

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CheckoutRepository(dio);
});

class CheckoutRepository {
  final Dio _dio;

  CheckoutRepository(this._dio);

  Future<OrderResponse> checkout(OrderRequest request) async {
    try {
      final response = await _dio.post(
        '/orders/checkout/',
        data: request.toJson(),
      );
      return OrderResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 && e.response?.data != null) {
        throw ApiException("Gagal checkout: ${e.response?.data}");
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<void> uploadPaymentProof({
    required String publicId,
    required String accessToken,
    required File imageFile,
  }) async {
    try {
      String fileName = imageFile.path.split('/').last;
      
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      await _dio.post(
        '/orders/$publicId/upload-proof/',
        data: formData,
        options: Options(
          headers: {
            'X-Order-Token': accessToken,
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ApiException("Bukti pembayaran untuk order ini sudah diupload.");
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      final response = await _dio.get('/core/payments/');
      final data = response.data as List;
      return data.map((json) => PaymentMethod.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<StoreContact?> getWhatsAppContact() async {
    try {
      final response = await _dio.get('/core/contacts/');
      final responseData = response.data;
      final List<dynamic> data;

      if (responseData is List) {
        data = responseData;
      } else if (responseData is Map<String, dynamic> &&
          responseData['results'] is List) {
        data = responseData['results'] as List<dynamic>;
      } else {
        return null;
      }

      final contacts = data
          .whereType<Map<String, dynamic>>()
          .map(StoreContact.fromJson)
          .toList();

      final waContact = contacts
          .where((c) => c.platform.toLowerCase() == 'whatsapp')
          .firstOrNull;
      return waContact;
    } catch (e) {
      return null;
    }
  }
}