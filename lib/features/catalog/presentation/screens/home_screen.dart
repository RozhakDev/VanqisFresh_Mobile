import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/catalog_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/promo_banner_carousel.dart';
import '../widgets/category_chips.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/products_section_header.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _searchFocused = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchFocusNode.addListener(() {
      setState(() => _searchFocused = _searchFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(productsProvider.notifier).fetchNextPage();
    }
  }

  void _onSearch(String value) {
    ref
        .read(productsProvider.notifier)
        .fetchInitialProducts(search: value.isEmpty ? null : value);
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final cartTotalItems = 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: _buildDrawer(context),
        body: RefreshIndicator(
          onRefresh: () async =>
              ref.read(productsProvider.notifier).fetchInitialProducts(),
          color: AppColors.primary,
          strokeWidth: 2.5,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              HomeAppBar(cartTotalItems: cartTotalItems),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: _SearchBar(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    focused: _searchFocused,
                    onSearch: _onSearch,
                  ),
                ),
              ),

              const PromoBannerCarousel(),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 4),
                  child: categoriesAsync.when(
                    data: (categories) => CategoryChips(
                      categories: categories,
                      onCategorySelected: (id) {
                        _searchController.clear();
                        ref
                            .read(productsProvider.notifier)
                            .fetchInitialProducts(categoryId: id);
                      },
                    ),
                    loading: () => const SizedBox(
                      height: 44,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: ProductsSectionHeader(
                  onViewAll: () {},
                  totalCount: productState.products.length,
                ),
              ),

              if (productState.error != null && productState.products.isEmpty)
                SliverFillRemaining(
                  child: _ErrorState(
                    message: productState.error!,
                    onRetry: () => ref
                        .read(productsProvider.notifier)
                        .fetchInitialProducts(),
                  ),
                )
              else if (productState.products.isEmpty && !productState.isLoading)
                const SliverFillRemaining(
                  child: _EmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          ProductCard(product: productState.products[index]),
                      childCount: productState.products.length,
                    ),
                  ),
                ),

              if (productState.isLoading && productState.products.isNotEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Drawer(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.eco_rounded, color: AppColors.primary, size: 36),
                ),
                const SizedBox(height: 12),
                Text(
                  authState.isAuthenticated 
                      ? 'Halo, ${authState.user?.firstName ?? "User"}!' 
                      : 'VanqisFresh',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  authState.isAuthenticated
                      ? '${authState.user?.phoneNumber}'
                      : 'Sistem Pemesanan Cepat',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          if (!authState.isAuthenticated) ...[
            ListTile(
              leading: const Icon(Icons.login_rounded, color: AppColors.textPrimary),
              title: Text(
                'Masuk / Daftar',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/login');
              },
            ),
            const Divider(),
          ],

          if (authState.isAuthenticated) ...[
            ListTile(
              leading: const Icon(Icons.person_rounded, color: AppColors.textPrimary),
              title: Text(
                'Profil & Akun',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/profile');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.receipt_long_rounded, color: AppColors.textPrimary),
              title: Text(
                'Riwayat Pesanan',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/orders');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined, color: AppColors.textPrimary),
              title: Text(
                'Keranjang Belanja',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/checkout');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: Text(
                'Keluar',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.error),
              ),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authProvider.notifier).logout();
              },
            ),
          ]
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool focused;
  final ValueChanged<String> onSearch;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.focused,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(
            Icons.search_rounded,
            color: AppColors.textHint,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onSubmitted: onSearch,
              onChanged: (v) {
                if (v.isEmpty) onSearch('');
              },
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Cari buah & sayur...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textHint,
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                isDense: true,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onSearch('');
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.textHint,
                  size: 22,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primaryMuted,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.search_off_rounded,
            size: 52,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Produk Tidak Ditemukan',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Coba kata kunci lain atau\nlihat semua kategori produk kami.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.wifi_off_rounded,
            size: 48,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Gagal Memuat Data',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Periksa koneksi internet kamu\nlalu coba lagi.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Coba Lagi'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }
}