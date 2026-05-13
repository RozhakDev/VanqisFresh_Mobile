import 'package:dio/dio.dart';

/// Mewakili error aplikasi dengan pesan yang mudah dipahami pengguna.
///
/// Digunakan untuk menyederhanakan error dari request API.
class ApiException implements Exception {
  final String message;

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat ApiException perlu dibuat dengan nilai awal.
  ApiException(this.message);

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat ApiException perlu dibuat dengan nilai awal.
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

  /// Mengubah kode status API menjadi pesan yang mudah dipahami.
  ///
  /// Pesan ini ditampilkan saat request gagal.
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

  /// Menghasilkan pesan error dalam bentuk teks.
  ///
  /// Digunakan saat exception perlu ditampilkan sebagai string.
  @override
  String toString() => message;
}
