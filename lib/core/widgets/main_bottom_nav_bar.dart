import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Menampilkan komponen UI untuk kebutuhan halaman terkait.
///
/// Komponen ini membantu menyusun tampilan agar konsisten dan mudah digunakan.
class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;

  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat MainBottomNavBar perlu dibuat dengan nilai awal.
  const MainBottomNavBar({super.key, required this.currentIndex});

  /// Membangun tampilan berdasarkan context dan state saat ini.
  ///
  /// Digunakan oleh Flutter untuk merender UI terbaru.
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) return;

        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/orders');
            break;
          case 2:
            context.go('/checkout');
            break;
          case 3:
            context.go('/profile');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryDark,
      unselectedItemColor: AppColors.textHint,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedFontSize: 10,
      unselectedFontSize: 10,
      selectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800),
      unselectedLabelStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600),
      elevation: 20,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Pesanan'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Keranjang'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profil'),
      ],
    );
  }
}
