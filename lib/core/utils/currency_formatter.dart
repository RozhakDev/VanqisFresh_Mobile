import 'package:intl/intl.dart';

/// Menyediakan utilitas format mata uang Rupiah.
///
/// Digunakan agar tampilan harga konsisten di seluruh aplikasi.
class CurrencyFormat {
  /// Mengubah nilai angka menjadi format Rupiah.
  ///
  /// Hasilnya dipakai untuk menampilkan harga dan total belanja.
  static String convertToIdr(dynamic number, {int decimalDigit = 0}) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: decimalDigit,
    );
    return currencyFormatter.format(number);
  }
}
