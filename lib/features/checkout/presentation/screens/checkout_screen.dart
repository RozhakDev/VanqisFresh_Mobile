import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/models/checkout_models.dart';
import '../providers/checkout_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _noteController = TextEditingController();
  
  String _selectedPaymentMethod = 'transfer'; // 'transfer' atau 'whatsapp'

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    final cartItems = ref.read(cartProvider);
    if (cartItems.isEmpty) return;

    if (_selectedPaymentMethod == 'whatsapp') {
      _processWhatsAppOrder();
    } else {
      _processTransferOrder();
    }
  }

  void _processWhatsAppOrder() async {
    final name = _nameController.text;
    final note = _noteController.text;
    final cartItems = ref.read(cartProvider);
    final totalPrice = ref.read(cartProvider.notifier).totalPrice;

    String itemsText = cartItems.map((e) => "- ${e.product.name} (${e.quantity}x)").join('\n');
    String msg = "Halo VanqisMart,\nSaya ingin memesan:\n$itemsText\n\nTotal: ${CurrencyFormat.convertToIdr(totalPrice)}\nNama: $name\nCatatan: $note";
    
    final waUrl = Uri.parse("https://wa.me/6283847921480?text=${Uri.encodeComponent(msg)}");
    if (await canLaunchUrl(waUrl)) {
      await launchUrl(waUrl, mode: LaunchMode.externalApplication);
      if(mounted) {
         ref.read(cartProvider.notifier).clearCart();
         context.go('/');
      }
    }
  }

  void _processTransferOrder() async {
    final cartItems = ref.read(cartProvider);
    final request = OrderRequest(
      customerName: _nameController.text.trim(),
      customerContact: _contactController.text.trim(),
      note: _noteController.text.trim(),
      items: cartItems.map((e) => OrderItemRequest(productId: e.product.id, quantity: e.quantity)).toList(),
    );

    final success = await ref.read(checkoutNotifierProvider.notifier).submitOrder(request);
    
    if (success && mounted) {
      final orderResp = ref.read(checkoutNotifierProvider).orderResponse;
      if (orderResp != null) {
        context.pushReplacement('/upload-proof/${orderResp.publicId}');
      }
    } else if (mounted) {
      final error = ref.read(checkoutNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Gagal checkout'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutNotifierProvider);
    final totalPrice = ref.read(cartProvider.notifier).totalPrice;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: checkoutState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informasi Pemesan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
                      validator: (val) => val == null || val.isEmpty ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contactController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'No WhatsApp / HP', border: OutlineInputBorder()),
                      validator: (val) => val == null || val.isEmpty ? 'Kontak wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Catatan (Opsional)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 24),
                    
                    const Text('Metode Pemesanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    RadioListTile<String>(
                      title: const Text('Transfer Bank / QRIS'),
                      subtitle: const Text('Upload bukti transfer di akhir pesanan'),
                      value: 'transfer',
                      groupValue: _selectedPaymentMethod,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
                    ),
                    RadioListTile<String>(
                      title: const Text('Pesan via WhatsApp'),
                      subtitle: const Text('Transaksi manual lewat chat admin'),
                      value: 'whatsapp',
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: checkoutState.isLoading ? null : _processCheckout,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: Text(
              _selectedPaymentMethod == 'whatsapp' 
                  ? 'Pesan Sekarang via WA' 
                  : 'Bayar ${CurrencyFormat.convertToIdr(totalPrice)}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}