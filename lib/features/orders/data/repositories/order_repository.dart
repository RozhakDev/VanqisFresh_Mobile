import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(dioProvider));
});

/// Mengelola akses data dan komunikasi dengan layanan terkait.
///
/// Class ini menjadi penghubung antara fitur dan sumber data.
class OrderRepository {
  final Dio _dio;

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat OrderRepository perlu dibuat dengan nilai awal.
  OrderRepository(this._dio);

  /// Mengirim data checkout dan mengembalikan detail pembayaran.
  ///
  /// Digunakan saat pengguna menyelesaikan pesanan.
  Future<Map<String, dynamic>> checkout(String note, List<Map<String, dynamic>> items) async {
    try {
      final response = await _dio.post('/orders/checkout/', data: {
        'note': note,
        'items': items,
      });
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception('Terjadi kesalahan\nCoba lagi ya');
      }
      throw Exception('Checkout belum berhasil\nCoba lagi ya');
    }
  }

  /// Mengambil daftar metode pembayaran yang tersedia.
  ///
  /// Data ini ditampilkan saat pengguna perlu memilih pembayaran.
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final response = await _dio.get('/core/payments/');
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      } else if (response.data is Map && response.data['results'] != null) {
        return List<Map<String, dynamic>>.from(response.data['results']);
      }
      return [];
    } catch (e) {
      throw Exception('Terjadi kesalahan\nCoba lagi ya');
    }
  }

  /// Mengunggah gambar bukti pembayaran untuk pesanan.
  ///
  /// Dipakai setelah pengguna menyelesaikan pembayaran manual.
  Future<void> uploadPaymentProof(String publicId, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });

      await _dio.post(
        '/orders/$publicId/upload-proof/',
        data: formData,
      );
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception('Terjadi kesalahan server\nCoba lagi');
      }
      throw Exception('Upload bukti belum berhasil\nCoba lagi ya');
    }
  }

  /// Mengambil nomor WhatsApp yang digunakan untuk checkout.
  ///
  /// Nomor ini dipakai untuk membuat pesan pesanan.
  Future<String> getWhatsAppContact() async {
    try {
      final response = await _dio.get('/core/contacts/');
      List dataList;
      
      if (response.data is List) {
        dataList = response.data;
      } else if (response.data is Map && response.data['results'] != null) {
        dataList = response.data['results'];
      } else {
        throw Exception('Belum bisa ambil kontak WhatsApp\nCoba lagi');
      }

      final wa = dataList.firstWhere(
        (e) => e['platform'].toString().toLowerCase() == 'whatsapp',
        orElse: () => null,
      );
      
      if (wa != null && wa['account_id'] != null) {
        return wa['account_id'].toString();
      }
      throw Exception('Nomor WhatsApp belum tersedia\nHubungi admin ya');
    } catch (e) {
      throw Exception('Belum bisa ambil kontak WhatsApp\nCoba lagi');
    }
  }

  /// Mengambil daftar pesanan pengguna dari server.
  ///
  /// Data ini ditampilkan pada halaman riwayat pesanan.
  Future<Map<String, dynamic>> getOrders({String? nextUrl}) async {
    try {
      final response = await _dio.get(nextUrl ?? '/orders/');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception('Terjadi kesalahan\nCoba lagi ya');
      }
      throw Exception('Riwayat pesanan belum muncul\nCoba lagi ya');
    }
  }

  /// Mengambil detail pesanan berdasarkan public ID.
  ///
  /// Detail ini dipakai pada halaman informasi pesanan.
  Future<Map<String, dynamic>> getOrderDetail(String publicId) async {
    try {
      final response = await _dio.get('/orders/$publicId/');
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Pesanan tidak ditemukan');
      }
      if (e.response != null && e.response!.data != null) {
        throw Exception('Terjadi kesalahan\nCoba lagi ya');
      }
      throw Exception('Detail pesanan belum bisa dimuat\nCoba lagi');
    }
  }
}
