import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/models/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

/// Mengelola akses data dan komunikasi dengan layanan terkait.
///
/// Class ini menjadi penghubung antara fitur dan sumber data.
class AuthRepository {
  final Dio _dio;

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat AuthRepository perlu dibuat dengan nilai awal.
  AuthRepository(this._dio);

  /// Mengirim data pendaftaran pengguna baru.
  ///
  /// Digunakan untuk membuat akun sebelum pengguna masuk.
  Future<void> register({
    required String username,
    required String password,
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String address,
  }) async {
    try {
      await _dio.post('/users/register/', data: {
        'username': username,
        'password': password,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'address': address,
      });
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final data = e.response!.data as Map;
        final errors = data.values.expand((v) => v is List ? v : [v]).join('\n');
        throw Exception(errors.isNotEmpty ? errors : 'Daftar belum berhasil\nCoba lagi ya');
      }
      throw Exception('Lagi ada gangguan koneksi\nCoba lagi ya');
    }
  }

  /// Memverifikasi email pengguna dengan kode OTP.
  ///
  /// Dipakai untuk memastikan alamat email sudah aktif.
  Future<void> verifyEmail(String email, String otp) async {
    try {
      await _dio.post('/users/verify-email/', data: {
        'email': email,
        'otp_code': otp,
      });
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final err = e.response!.data as Map;
        final errors = err.values.expand((v) => v is List ? v : [v]).join('\n');
        throw Exception(errors.isNotEmpty ? errors : 'Verifikasi belum berhasil\nCoba lagi ya');
      }
      throw Exception('Verifikasi belum berhasil\nCoba lagi ya');
    }
  }

  /// Mengirim ulang kode OTP ke email pengguna.
  ///
  /// Digunakan saat pengguna meminta kode baru.
  Future<void> resendOtp(String email) async {
    try {
      await _dio.post('/users/resend-otp/', data: {
        'email': email,
      });
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final err = e.response!.data as Map;
        final errors = err.values.expand((v) => v is List ? v : [v]).join('\n');
        throw Exception(errors.isNotEmpty ? errors : 'Kode gagal dikirim ulang\nCoba sebentar lagi');
      }
      throw Exception('Kode gagal dikirim ulang\nCoba sebentar lagi');
    }
  }

  /// Memproses login pengguna dan mengembalikan hasilnya.
  ///
  /// Digunakan untuk membuka sesi pengguna di aplikasi.
  Future<Map<String, String>> login(String email, String password) async {
    try {
      final response = await _dio.post('/users/login/', data: {
        'username': email,
        'password': password,
      });

      return {
        'access': response.data['access'],
        'refresh': response.data['refresh'],
      };
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final data = e.response!.data as Map;
        if (data.containsKey('errors')) {
          final errors = data['errors'] as Map;
          if (errors['is_verified'] != null && errors['is_verified'].toString() == '[False]') {
             throw Exception('UNVERIFIED:$email');
          }
          final errorMessages = errors.values.expand((v) => v is List ? v : [v]).join('\n');
          throw Exception(errorMessages.isNotEmpty ? errorMessages : 'Login belum berhasil\nCek lagi datanya ya');
        }
        if (data.containsKey('detail')) {
          throw Exception('Login belum berhasil\nCoba lagi ya');
        }
      }
      throw Exception('Login belum berhasil\nCek lagi datanya ya');
    }
  }

  /// Memuat profil pengguna yang sedang login.
  ///
  /// Data ini dipakai untuk menampilkan informasi akun.
  Future<User> fetchProfile() async {
    try {
      final response = await _dio.get('/users/profile/');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Profil belum bisa dimuat\nCoba lagi nanti');
    }
  }

  /// Memperbarui data profil pengguna.
  ///
  /// Digunakan setelah pengguna menyimpan perubahan profil.
  Future<User> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('/users/profile/', data: data);
      return User.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final err = e.response!.data as Map;
        final errors = err.values.expand((v) => v is List ? v : [v]).join('\n');
        throw Exception(errors.isNotEmpty ? errors : 'Profil belum bisa dimuat\nCoba lagi nanti');
      }
      throw Exception('Koneksi lagi bermasalah\nCoba ulangi');
    }
  }

  /// Menyimpan token sesi pengguna secara lokal.
  ///
  /// Token ini dipakai untuk request berikutnya.
  Future<void> saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  /// Menghapus token sesi pengguna dari penyimpanan lokal.
  ///
  /// Dipakai saat sesi pengguna harus dibersihkan.
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  /// Memeriksa apakah token pengguna masih tersimpan.
  ///
  /// Hasilnya dipakai untuk menentukan status sesi pengguna.
  Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('access_token');
  }
}
