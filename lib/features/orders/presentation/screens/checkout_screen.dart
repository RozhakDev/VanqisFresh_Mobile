import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../catalog/presentation/widgets/product_image_placeholder.dart';
import '../../data/repositories/order_repository.dart';
import '../providers/cart_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _processApiCheckout() async {
    final cartItems = ref.read(cartProvider);
    if (cartItems.isEmpty) return;

    setState(() => _isLoading = true);
    
    try {
      final items = cartItems.map((c) => {
        'product_id': c.product.id,
        'quantity': c.quantity,
      }).toList();

      final repository = ref.read(orderRepositoryProvider);
      final response = await repository.checkout(_noteController.text.trim(), items);
      
      ref.read(cartProvider.notifier).clearCart();
      
      if (!mounted) return;
      SnackbarUtils.show(context, 'Pesanan berhasil dibuat!', type: SnackbarType.success);
      
      final publicId = response['public_id'];
      if (publicId != null) {
        context.go('/payment/$publicId');
      } else {
        context.go('/');
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.show(context, e.toString().replaceAll('Exception: ', ''), type: SnackbarType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _processWaCheckout() async {
    final cartItems = ref.read(cartProvider);
    if (cartItems.isEmpty) return;

    final user = ref.read(authProvider).user;
    if (user == null) {
      SnackbarUtils.show(context, 'Sesi berakhir. Silakan masuk kembali.', type: SnackbarType.error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(orderRepositoryProvider);
      final waPhone = await repository.getWhatsAppContact();

      StringBuffer text = StringBuffer();
      text.writeln('Halo VanqisFresh, saya ingin memesan:');
      for (int i = 0; i < cartItems.length; i++) {
        final c = cartItems[i];
        text.writeln('${i+1}. ${c.product.name} (x${c.quantity})');
      }
      text.writeln();
      text.writeln('Catatan: ${_noteController.text.trim().isEmpty ? "-" : _noteController.text.trim()}');
      text.writeln('Total: ${CurrencyFormat.convertToIdr(ref.read(cartProvider.notifier).totalPrice)}');
      text.writeln();
      text.writeln('Identitas Pengiriman:');
      text.writeln('Nama: ${user.firstName} ${user.lastName}');
      text.writeln('Alamat: ${user.address}');
      text.writeln('No HP: ${user.phoneNumber}');

      final encodedText = Uri.encodeComponent(text.toString());
      final finalUrl = Uri.parse('whatsapp://send?phone=$waPhone&text=$encodedText');

      final launched = await launchUrl(finalUrl, mode: LaunchMode.externalApplication);
      if (!launched) {
        throw Exception('Tidak dapat membuka WhatsApp. Pastikan WhatsApp terinstal di perangkat Anda.');
      }
      ref.read(cartProvider.notifier).clearCart();
      if (mounted) context.go('/');
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.show(context, e.toString().replaceAll('Exception: ', ''), type: SnackbarType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final totalPrice = ref.read(cartProvider.notifier).totalPrice;
    final user = ref.watch(authProvider).user;

    Widget bodyContent;
    if (cartItems.isEmpty) {
      bodyContent = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.textHint),
            const SizedBox(height: 24),
            Text('Masih Kosong', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Yuk, mulai belanja sayur dan buah segar!', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text('Mulai Belanja'),
            ),
          ],
        ),
      );
    } else {
      bodyContent = _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text('Identitas Pengiriman', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_rounded, color: AppColors.primary, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                user?.firstName != null ? '${user?.firstName} ${user?.lastName}' : 'User',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.phone_rounded, color: AppColors.textHint, size: 16),
                            const SizedBox(width: 8),
                            Text(user?.phoneNumber ?? '-', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_rounded, color: AppColors.textHint, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(user?.address ?? 'Alamat belum diatur', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Rincian Pesanan', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: cartItems.map((item) {
                        final String imageUrl = item.product.image;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 52, 
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.background, 
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border)
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
                                        errorWidget: (context, url, error) => const ProductImagePlaceholder(iconSize: 24),
                                      )
                                    : const ProductImagePlaceholder(iconSize: 24, iconColor: AppColors.primaryDark),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(item.product.name, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(CurrencyFormat.convertToIdr(item.product.price * item.quantity), style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppColors.primaryDark, fontSize: 14)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${CurrencyFormat.convertToIdr(item.product.price)} / ${item.product.unit}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (item.quantity == 1) {
                                                  ref.read(cartProvider.notifier).removeItem(item.product.id);
                                                } else {
                                                  ref.read(cartProvider.notifier).updateQuantity(item.product.id, item.quantity - 1);
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: item.quantity == 1 ? AppColors.error.withValues(alpha: 0.1) : Colors.transparent,
                                                  border: Border.all(color: item.quantity == 1 ? Colors.transparent : AppColors.border),
                                                  borderRadius: BorderRadius.circular(6)
                                                ),
                                                child: Icon(item.quantity == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded, size: 16, color: item.quantity == 1 ? AppColors.error : AppColors.textPrimary),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 32,
                                              child: Text(
                                                item.quantity.toString(),
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                if (item.quantity < item.product.stock) {
                                                  ref.read(cartProvider.notifier).updateQuantity(item.product.id, item.quantity + 1);
                                                } else {
                                                  SnackbarUtils.show(context, 'Jumlah melebihi stok tersedia.', type: SnackbarType.warning);
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: AppColors.border),
                                                  borderRadius: BorderRadius.circular(6),
                                                  color: item.quantity >= item.product.stock ? AppColors.background : Colors.transparent,
                                                ),
                                                child: Icon(Icons.add_rounded, size: 16, color: item.quantity >= item.product.stock ? AppColors.textHint : AppColors.textPrimary),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Catatan', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Cth: Tolong pilihkan buah yang masih mengkal.',
                      hintStyle: GoogleFonts.inter(color: AppColors.textHint, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: AppColors.bottomBarShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Pembayaran', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      Text(CurrencyFormat.convertToIdr(totalPrice), style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _processWaCheckout,
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                          label: const Text('WhatsApp'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF25D366),
                            side: const BorderSide(color: Color(0xFF25D366), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: _processApiCheckout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text('Buat Pesanan', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textOnPrimary)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(
          'Keranjang Belanja',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_accounts_outlined, color: AppColors.textPrimary),
            tooltip: 'Ubah Profil',
            onPressed: () => context.push('/profile'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: bodyContent,
    );
  }
}