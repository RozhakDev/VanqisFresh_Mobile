import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/repositories/checkout_repository.dart';
import '../../domain/models/checkout_models.dart';
import '../../domain/models/payment_method.dart';

final paymentMethodProvider = FutureProvider<List<PaymentMethod>>((ref) async {
  return ref.watch(checkoutRepositoryProvider).getPaymentMethods();
});

class CheckoutState {
  final bool isLoading;
  final String? error;
  final OrderResponse? orderResponse;

  CheckoutState({this.isLoading = false, this.error, this.orderResponse});
}

final checkoutNotifierProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  final repo = ref.watch(checkoutRepositoryProvider);
  return CheckoutNotifier(repo);
});

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final CheckoutRepository _repository;

  CheckoutNotifier(this._repository) : super(CheckoutState());

  Future<bool> submitOrder(OrderRequest request) async {
    state = CheckoutState(isLoading: true);
    try {
      final response = await _repository.checkout(request);
      state = CheckoutState(isLoading: false, orderResponse: response);
      return true;
    } catch (e) {
      state = CheckoutState(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> uploadProof(File imageFile) async {
    if (state.orderResponse == null) {
      state = CheckoutState(error: "Order token tidak ditemukan. Silakan ulangi pesanan.");
      return false;
    }

    state = CheckoutState(isLoading: true, orderResponse: state.orderResponse);

    try {
      await _repository.uploadPaymentProof(
        publicId: state.orderResponse!.publicId,
        accessToken: state.orderResponse!.accessToken,
        imageFile: imageFile,
      );
      state = CheckoutState(isLoading: false, orderResponse: state.orderResponse);
      return true;
    } catch (e) {
      state = CheckoutState(
        isLoading: false, 
        error: e.toString(), 
        orderResponse: state.orderResponse
      );
      return false;
    }
  }
}