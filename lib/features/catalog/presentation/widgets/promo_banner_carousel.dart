import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/catalog_provider.dart';
import 'promo_products_sheet.dart';
import '../../domain/models/promo.dart';

/// Menampilkan komponen UI untuk kebutuhan halaman terkait.
///
/// Komponen ini membantu menyusun tampilan agar konsisten dan mudah digunakan.
class PromoBannerCarousel extends ConsumerWidget {
  /// Membuat instance dengan data yang dibutuhkan.
  ///
  /// Digunakan saat PromoBannerCarousel perlu dibuat dengan nilai awal.
  const PromoBannerCarousel({super.key});

  /// Membangun tampilan berdasarkan context dan state saat ini.
  ///
  /// Digunakan oleh Flutter untuk merender UI terbaru.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promosAsync = ref.watch(promosProvider);

    return promosAsync.when(
      data: (promos) {
        final activePromos =
            promos.where((p) => p.isActive).toList();
        if (activePromos.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

        return SliverToBoxAdapter(
          child: _PromoCarouselWidget(promos: activePromos),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _PromoSkeletonLoader(),
        ),
      ),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }
}

/// Menampilkan komponen UI untuk kebutuhan halaman terkait.
///
/// Komponen ini membantu menyusun tampilan agar konsisten dan mudah digunakan.
class _PromoCarouselWidget extends StatefulWidget {
  final List<Promo> promos;

  const _PromoCarouselWidget({required this.promos});

  /// Membuat state yang mengelola perilaku widget.
  ///
  /// State ini menyimpan interaksi dan perubahan lokal widget.
  @override
  State<_PromoCarouselWidget> createState() => _PromoCarouselWidgetState();
}

/// Menyimpan state yang dibutuhkan fitur terkait.
///
/// Data ini dipakai untuk menentukan tampilan dan proses fitur.
class _PromoCarouselWidgetState extends State<_PromoCarouselWidget> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  static const List<List<Color>> _gradients = [
    [Color(0xFFEAB308), Color(0xFFFDE047)], // Warm Yellow
    [Color(0xFF134E4A), Color(0xFF065F46)], // Dark Green
    [Color(0xFFF97316), Color(0xFFFB923C)], // Orange
  ];

  /// Menyiapkan state awal saat widget dibuat.
  ///
  /// Digunakan untuk inisialisasi sebelum tampilan pertama dirender.
  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _startAutoScroll();
  }

  /// Membersihkan resource saat widget tidak lagi digunakan.
  ///
  /// Dipanggil untuk melepas controller, listener, atau timer.
  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// Memulai perpindahan banner promo secara otomatis.
  ///
  /// Digunakan agar promo berganti tanpa interaksi pengguna.
  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted && widget.promos.length > 1) {
        final next = (_currentPage + 1) % widget.promos.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  /// Memilih gradasi warna berdasarkan posisi banner.
  ///
  /// Warna membantu setiap promo terlihat berbeda.
  List<Color> _getGradient(int index) {
    return _gradients[index % _gradients.length];
  }

  /// Membangun tampilan berdasarkan context dan state saat ini.
  ///
  /// Digunakan oleh Flutter untuk merender UI terbaru.
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 148,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.promos.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final promo = widget.promos[index];
              final gradient = _getGradient(index);
              return _PromoBannerCard(
                promo: promo,
                gradient: gradient,
              );
            },
          ),
        ),

        if (widget.promos.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.promos.length,
              (index) => _DotIndicator(
                isActive: index == _currentPage,
                color: _getGradient(index)[0],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// Menampilkan komponen UI untuk kebutuhan halaman terkait.
///
/// Komponen ini membantu menyusun tampilan agar konsisten dan mudah digunakan.
class _PromoBannerCard extends StatelessWidget {
  final Promo promo;
  final List<Color> gradient;

  const _PromoBannerCard({required this.promo, required this.gradient});

  /// Membangun tampilan berdasarkan context dan state saat ini.
  ///
  /// Digunakan oleh Flutter untuk merender UI terbaru.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -30,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            if (promo.products.isNotEmpty && promo.products.first.image.isNotEmpty)
              Positioned(
                right: 16,
                bottom: 0,
                top: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: promo.products.first.image,
                    width: 110,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const SizedBox(width: 110),
                    errorWidget: (_, __, ___) => const SizedBox(width: 110),
                  ),
                ),
              ),

            Positioned(
              left: 20,
              top: 20,
              right: 130,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1917),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Promo Spesial',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      promo.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  if (promo.description.isNotEmpty) ...[
                    Text(
                      promo.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () => PromoProductsSheet.show(context, promo),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        child: Text(
                          'Lihat Promo',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Menampilkan komponen UI untuk kebutuhan halaman terkait.
///
/// Komponen ini membantu menyusun tampilan agar konsisten dan mudah digunakan.
class _DotIndicator extends StatelessWidget {
  final bool isActive;
  final Color color;

  const _DotIndicator({required this.isActive, required this.color});

  /// Membangun tampilan berdasarkan context dan state saat ini.
  ///
  /// Digunakan oleh Flutter untuk merender UI terbaru.
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: isActive ? 20 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? color : AppColors.border,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

/// Menampilkan komponen UI untuk kebutuhan halaman terkait.
///
/// Komponen ini membantu menyusun tampilan agar konsisten dan mudah digunakan.
class _PromoSkeletonLoader extends StatelessWidget {
  const _PromoSkeletonLoader();

  /// Membangun tampilan berdasarkan context dan state saat ini.
  ///
  /// Digunakan oleh Flutter untuk merender UI terbaru.
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 148,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}
