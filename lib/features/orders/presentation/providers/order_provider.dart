import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/order_repository.dart';
import '../../domain/models/order_models.dart';

const _orderHistoryKey = 'vanqismart_order_history';

final orderDetailProvider = FutureProvider.family<OrderDetail, LocalOrder>((ref, localOrder) async {
  return ref.watch(orderRepositoryProvider).getOrderDetail(localOrder.publicId, localOrder.accessToken);
});

final orderHistoryProvider = NotifierProvider<OrderHistoryNotifier, List<LocalOrder>>(() {
  return OrderHistoryNotifier();
});

class OrderHistoryNotifier extends Notifier<List<LocalOrder>> {
  @override
  List<LocalOrder> build() {
    _loadHistory();
    return [];
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_orderHistoryKey);
    if (historyJson != null) {
      final history = historyJson.map((item) => LocalOrder.fromJson(jsonDecode(item))).toList();
      history.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = history;
    }
  }

  Future<void> saveOrder(String publicId, String accessToken) async {
    if (state.any((order) => order.publicId == publicId)) return;

    final newOrder = LocalOrder(
      publicId: publicId,
      accessToken: accessToken,
      createdAt: DateTime.now(),
    );

    state = [newOrder, ...state];

    final prefs = await SharedPreferences.getInstance();
    final historyList = state.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_orderHistoryKey, historyList);
  }
}