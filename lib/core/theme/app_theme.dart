import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';


/// Menyimpan daftar palet warna resmi yang digunakan di seluruh aplikasi.
///
/// Class ini memastikan agar penggunaan warna UI konsisten dan
/// selaras dengan identitas merek perusahaan.
class AppColors {
  static const Color primary = Color(0xFFEAB308);
  static const Color primaryDark = Color(0xFF134E4A);
  static const Color primaryLight = Color(0xFFFDE047);
  
  static const Color brandYellow = Color(0xFFEAB308);
  static const Color brandOrange = Color(0xFFF97316);
  static const Color brandRed    = Color(0xFFEF4444);

  static const Color primaryMuted = Color(0xFFFEF9C3);
  static const Color primarySurface = Color(0xFFFEFCE8);
  static const Color accentGreen  = Color(0xFF16A34A);
  static const Color accentRed    = Color(0xFFFF4038);
  static const Color accentOrange = Color(0xFFEA580C);
  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color accentBlue   = Color(0xFF2563EB);

  static const Color background = Color(0xFFF4F7F5);
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color border     = Color(0xFFE5E7EB);
  static const Color divider    = Color(0xFFE5E7EB);
  static const Color section    = Color(0xFFF3F4F6);

  static const Color textPrimary   = Color(0xFF134E4A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint      = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color error   = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFACC15);
  static const Color info    = Color(0xFF3B82F6);

  /// Memberikan efek bayangan lembut untuk komponen berbentuk kartu.
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF134E4A).withValues(alpha: 0.04),
      blurRadius: 14,
      offset: const Offset(0, 4),
    ),
  ];

  /// Memberikan efek bayangan sangat halus untuk elemen UI sekunder.
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0xFF134E4A).withValues(alpha: 0.03),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Memberikan efek bayangan mengambang khusus untuk bilah navigasi bawah.
  static List<BoxShadow> get bottomBarShadow => [
    BoxShadow(
      color: const Color(0xFF134E4A).withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, -4),
    ),
  ];

  /// Memberikan efek pendaran berwarna utama pada tombol atau elemen aktif.
  static List<BoxShadow> get primaryGlow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.25),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}


/// Mengelola konfigurasi gaya dan tema global aplikasi secara terpusat.
///
/// Class ini menyatukan warna, tipografi, dan gaya komponen bawaan 
/// Flutter agar seragam di semua halaman.
class AppTheme {
  /// Membangun konfigurasi tema terang (*Light Theme*) standar.
  ///
  /// Tema ini merombak warna dasar, gaya teks, hingga bentuk tombol
  /// sesuai pedoman UI/UX aplikasi.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        error: AppColors.error,
        surface: AppColors.surface,
        onPrimary: AppColors.textOnPrimary,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          fixedSize: const Size.fromHeight(48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          side: const BorderSide(color: AppColors.primaryDark, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          fixedSize: const Size.fromHeight(48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          fixedSize: const Size.fromHeight(48),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
    );
  }
}
