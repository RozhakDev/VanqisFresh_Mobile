import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../domain/models/product.dart';
import '../providers/catalog_provider.dart';
import '../widgets/product_image_placeholder.dart';
import '../../../orders/presentation/providers/cart_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  late AnimationController _fabAnimController;
  late Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _fabScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _fabAnimController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  void _onAddToCart(Product product) async {
    if (!product.isAvailable || product.stock <= 0) return;

    await _fabAnimController.forward();
    await _fabAnimController.reverse();

    HapticFeedback.mediumImpact();

    ref.read(cartProvider.notifier).addItem(product, _quantity);

    if (mounted) {
      SnackbarUtils.show(
        context,
        '${product.name} masuk keranjang',
        type: SnackbarType.success,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'LIHAT',
          textColor: AppColors.primaryLight,
          onPressed: () {
            context.push('/checkout');
          },
        ),
      );
    }
  }

  void _incrementQty(int maxStock) {
    if (_quantity < maxStock) {
      setState(() => _quantity++);
      HapticFeedback.selectionClick();
    }
  }

  void _decrementQty() {
    if (_quantity > 1) {
      setState(() => _quantity--);
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: productAsync.when(
        data: (product) => _buildContent(context, product),
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, __) => _buildError(error.toString(), ref),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Product product) {
    final isAvailable = product.isAvailable && product.stock > 0;
    final totalPrice = product.price * _quantity;

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: AppColors.surface,
                surfaceTintColor: Colors.transparent,
                leadingWidth: 64,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: AppColors.softShadow,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'product_detail_${product.id}',
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          color: AppColors.background,
                          child: product.image != null && product.image!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: product.image!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) =>
                                      const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                  errorWidget: (_, __, ___) => _buildPlaceholder(),
                                )
                              : _buildPlaceholder(),
                        ),
                      ),

                      if (!isAvailable)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.5),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Stok Habis',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryMuted,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.categoryName ?? 'Kategori',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                isAvailable ? Icons.inventory_2_rounded : Icons.info_outline_rounded, 
                                color: isAvailable ? AppColors.textSecondary : AppColors.error, 
                                size: 16
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isAvailable ? 'Sisa ${product.stock}' : 'Stok Habis',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isAvailable ? AppColors.textSecondary : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text(
                        product.name,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormat.convertToIdr(product.price),
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '/ per ${product.unit}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textHint,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 24),

                      Text(
                        'Deskripsi Produk',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description.isEmpty
                            ? 'Produk berkualitas tinggi, organik, dan dipastikan selalu segar hingga ke tangan Anda.'
                            : product.description,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: AppColors.bottomBarShadow,
            border: const Border(top: BorderSide(color: AppColors.border, width: 0.5)),
          ),
          child: Row(
            children: [
              if (isAvailable) ...[
                Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildQtyBtn(Icons.remove_rounded, _quantity > 1, () => _decrementQty()),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '$_quantity',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _buildQtyBtn(Icons.add_rounded, _quantity < product.stock, () => _incrementQty(product.stock)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
              
              Expanded(
                child: ScaleTransition(
                  scale: _fabScale,
                  child: GestureDetector(
                    onTap: isAvailable ? () => _onAddToCart(product) : null,
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: isAvailable ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: !isAvailable ? Border.all(color: AppColors.border) : null,
                        boxShadow: isAvailable
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          isAvailable
                              ? 'Tambah • ${CurrencyFormat.convertToIdr(totalPrice)}'
                              : 'Stok Terjual Habis',
                          style: GoogleFonts.inter(
                            color: isAvailable ? AppColors.textOnPrimary : AppColors.textHint,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.border,
      child: const ProductImagePlaceholder(iconSize: 80),
    );
  }

  Widget _buildQtyBtn(IconData icon, bool enabled, VoidCallback onTap) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 44,
        height: 54,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.textPrimary : AppColors.textHint,
        ),
      ),
    );
  }

  Widget _buildError(String msg, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 50, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Gagal', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(msg, style: GoogleFonts.inter(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.invalidate(productDetailProvider(widget.productId)),
            child: const Text('Coba Lagi'),
          )
        ],
      ),
    );
  }
}