import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Menampilkan komponen UI untuk kebutuhan halaman terkait.
///
/// Komponen ini membantu menyusun tampilan agar konsisten dan mudah digunakan.
class ProductImagePlaceholder extends StatelessWidget {
  final double iconSize;
  final Color iconColor;

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat ProductImagePlaceholder perlu dibuat dengan nilai awal.
  const ProductImagePlaceholder({
    super.key,
    this.iconSize = 28,
    this.iconColor = AppColors.textHint,
  });

  /// Membangun tampilan berdasarkan context dan state saat ini.
  ///
  /// Digunakan oleh Flutter untuk merender UI terbaru.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.local_grocery_store_outlined,
        color: iconColor,
        size: iconSize,
      ),
    );
  }
}
