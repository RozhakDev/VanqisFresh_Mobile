import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/catalog_provider.dart';
import '../widgets/section_header.dart';
import '../../domain/models/promo.dart';

class PromoBannerCarousel extends ConsumerWidget {
  const PromoBannerCarousel({super.key});

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

class _PromoCarouselWidget extends StatefulWidget {
  final List<Promo> promos;

  const _PromoCarouselWidget({required this.promos});

  @override
  State<_PromoCarouselWidget> createState() => _PromoCarouselWidgetState();
}

class _PromoCarouselWidgetState extends State<_PromoCarouselWidget> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  static const List<List<Color>> _gradients = [
    [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    [Color(0xFFEA580C), Color(0xFFF97316)],
    [Color(0xFFD97706), Color(0xFFF59E0B)],
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

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

  List<Color> _getGradient(int index) {
    return _gradients[index % _gradients.length];
  }

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
        ],

        _PromoProductsSection(promos: widget.promos),
      ],
    );
  }
}

class _PromoBannerCard extends StatelessWidget {
  final Promo promo;
  final List<Color> gradient;

  const _PromoBannerCard({required this.promo, required this.gradient});

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
              color: gradient[0].withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Lihat Promo',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
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

class _DotIndicator extends StatelessWidget {
  final bool isActive;
  final Color color;

  const _DotIndicator({required this.isActive, required this.color});

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

class _PromoProductsSection extends ConsumerWidget {
  final List<Promo> promos;

  const _PromoProductsSection({required this.promos});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promosWithProducts =
        promos.where((p) => p.products.isNotEmpty).toList();
    if (promosWithProducts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: promosWithProducts.map((promo) {
        return _SinglePromoRow(promo: promo);
      }).toList(),
    );
  }
}

class _SinglePromoRow extends StatelessWidget {
  final Promo promo;

  const _SinglePromoRow({required this.promo});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          title: promo.title,
          subtitle: promo.description.isNotEmpty ? promo.description : null,
        ),
        SizedBox(
          height: 220,
          child: promo.products.length <= 2
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: promo.products.map((product) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: SizedBox(
                        width: 148,
                        child: _PromoProductMiniCard(product: product),
                      ),
                    );
                  }).toList(),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: promo.products.length,
                  itemBuilder: (context, index) {
                    final product = promo.products[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 148,
                        child: _PromoProductMiniCard(product: product),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _PromoProductMiniCard extends StatelessWidget {
  final dynamic product;

  const _PromoProductMiniCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: CachedNetworkImage(
                imageUrl: product.image,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: const Color(0xFFF3F4F6)),
                errorWidget: (_, __, ___) => Container(
                  color: const Color(0xFFF3F4F6),
                  child: const Icon(Icons.eco_rounded, color: AppColors.textHint, size: 32),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatRupiah(product.price),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatRupiah(dynamic price) {
    try {
      final num amount = price is num ? price : num.parse(price.toString());
      final intAmount = amount.toInt();
      final formatted = intAmount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
      return 'Rp $formatted';
    } catch (_) {
      return 'Rp -';
    }
  }
}

class _PromoSkeletonLoader extends StatelessWidget {
  const _PromoSkeletonLoader();

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