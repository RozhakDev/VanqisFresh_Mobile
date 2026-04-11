class OrderItemRequest {
  final int productId;
  final int quantity;

  OrderItemRequest({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'quantity': quantity,
      };
}

class OrderRequest {
  final String customerName;
  final String customerContact;
  final String? note;
  final List<OrderItemRequest> items;

  OrderRequest({
    required this.customerName,
    required this.customerContact,
    this.note,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'customer_name': customerName,
        'customer_contact': customerContact,
        'note': note ?? '',
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class OrderResponse {
  final String publicId;
  final String accessToken;
  final int totalPrice;
  final String status;

  OrderResponse({
    required this.publicId,
    required this.accessToken,
    required this.totalPrice,
    required this.status,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      publicId: json['public_id'] as String,
      accessToken: json['access_token'] as String,
      totalPrice: json['total_price'] as int,
      status: json['status'] as String,
    );
  }
}