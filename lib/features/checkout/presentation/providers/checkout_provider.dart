import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  CheckoutState copyWith({
    bool? isLoading,
    String? error,
    OrderResponse? orderResponse,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      orderResponse: orderResponse ?? this.orderResponse,
    );
  }
}

final checkoutNotifierProvider = NotifierProvider<CheckoutNotifier, CheckoutState>(() {
  return CheckoutNotifier();
});

class CheckoutNotifier extends Notifier<CheckoutState> {
  late CheckoutRepository _repository;

  @override
  CheckoutState build() {
    _repository = ref.watch(checkoutRepositoryProvider);
    return CheckoutState();
  }

  Future<bool> submitOrder(OrderRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.checkout(request);
      state = state.copyWith(isLoading: false, orderResponse: response);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> uploadProof(File imageFile) async {
    final orderResponse = state.orderResponse;
    if (orderResponse == null) {
      state = state.copyWith(error: "Order data not found. Please try checkout again.");
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.uploadPaymentProof(
        publicId: orderResponse.publicId,
        accessToken: orderResponse.accessToken,
        imageFile: imageFile,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    state = CheckoutState();
  }
}
