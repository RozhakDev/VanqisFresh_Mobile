import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/order_provider.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(orderHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pesanan')),
      body: history.isEmpty
          ? const Center(child: Text('Belum ada riwayat pesanan.', style: TextStyle(color: AppColors.textSecondary)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final localOrder = history[index];
                final dateFormatted = DateFormat('dd MMM yyyy, HH:mm').format(localOrder.createdAt);

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.background,
                      child: Icon(Icons.receipt, color: AppColors.primary),
                    ),
                    title: Text('Order ID: ${localOrder.publicId.split('-').first.toUpperCase()}', 
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(dateFormatted),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/orders/detail', extra: localOrder),
                  ),
                );
              },
            ),
    );
  }
}