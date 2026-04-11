import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  factory ApiException.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.cancel:
        return ApiException("Request ke server dibatalkan.");
      case DioExceptionType.connectionTimeout:
        return ApiException("Koneksi timeout. Periksa internet Anda.");
      case DioExceptionType.receiveTimeout:
        return ApiException("Server terlalu lama merespon.");
      case DioExceptionType.badResponse:
        return ApiException(_handleStatusCode(dioError.response?.statusCode));
      case DioExceptionType.connectionError:
        return ApiException("Tidak ada koneksi internet.");
      default:
        return ApiException("Terjadi kesalahan tak terduga.");
    }
  }

  static String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return "Permintaan tidak valid.";
      case 404:
        return "Data tidak ditemukan.";
      case 429:
        return "Terlalu banyak request. Tunggu beberapa saat.";
      case 500:
        return "Terjadi kesalahan pada server.";
      default:
        return "Oops, terjadi kesalahan. Kode: $statusCode";
    }
  }

  @override
  String toString() => message;
}