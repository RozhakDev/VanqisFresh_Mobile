import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

/// Menampilkan komponen UI untuk kebutuhan halaman terkait.
///
/// Komponen ini membantu menyusun tampilan agar konsisten dan mudah digunakan.
class ProductsSectionHeader extends StatelessWidget {
  final VoidCallback? onViewAll;
  final int totalCount;

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat ProductsSectionHeader perlu dibuat dengan nilai awal.
  const ProductsSectionHeader({
    super.key,
    this.onViewAll,
    required this.totalCount,
  });

  /// Membangun tampilan berdasarkan context dan state saat ini.
  ///
  /// Digunakan oleh Flutter untuk merender UI terbaru.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produk Segar Kami',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                if (totalCount > 0)
                  Text(
                    '$totalCount produk tersedia',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
