import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/models/order_models.dart';
import '../providers/order_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  final LocalOrder localOrder;
  const OrderDetailScreen({super.key, required this.localOrder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(localOrder));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: orderAsync.when(
        data: (order) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getStatusColor(order.status)),
                ),
                child: Column(
                  children: [
                    Text('Status Pesanan', style: TextStyle(color: _getStatusColor(order.status))),
                    const SizedBox(height: 4),
                    Text(order.status.toUpperCase(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _getStatusColor(order.status))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              const Text('Daftar Produk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${item.quantity}x ${item.productName}'),
                    Text(CurrencyFormat.convertToIdr(item.price * item.quantity), style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              )),
              const Divider(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(CurrencyFormat.convertToIdr(order.totalPrice), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 24),
              
              const Text('Informasi Pengiriman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text('Penerima: ${order.customerName}'),
              Text('Kontak: ${order.customerContact}'),
              if (order.note != null && order.note!.isNotEmpty) Text('Catatan: ${order.note}'),
              const SizedBox(height: 8),
              Text('Bukti Bayar: ${order.paymentProof}', style: const TextStyle(fontStyle: FontStyle.italic)),

              const SizedBox(height: 32),
              if (order.status == 'Pending' && order.paymentProof == 'Belum diunggah')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/upload-proof/${order.publicId}'),
                    child: const Text('Upload Bukti Transfer Sekarang'),
                  ),
                )
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString(), style: const TextStyle(color: AppColors.error))),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'Completed') return AppColors.primary;
    if (status == 'Confirmed') return Colors.blue;
    return Colors.orange;
  }
}