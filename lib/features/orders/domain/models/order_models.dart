class LocalOrder {
  final String publicId;
  final String accessToken;
  final DateTime createdAt;

  LocalOrder({
    required this.publicId,
    required this.accessToken,
    required this.createdAt,
  });

  factory LocalOrder.fromJson(Map<String, dynamic> json) => LocalOrder(
        publicId: json['publicId'] as String,
        accessToken: json['accessToken'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'publicId': publicId,
        'accessToken': accessToken,
        'createdAt': createdAt.toIso8601String(),
      };
}

class OrderDetail {
  final String publicId;
  final String customerName;
  final String customerContact;
  final String? note;
  final int totalPrice;
  final String status;
  final List<OrderItemDetail> items;
  final String paymentProof;
  final DateTime createdAt;

  OrderDetail({
    required this.publicId,
    required this.customerName,
    required this.customerContact,
    this.note,
    required this.totalPrice,
    required this.status,
    required this.items,
    required this.paymentProof,
    required this.createdAt,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
        publicId: json['public_id'] as String,
        customerName: json['customer_name'] as String,
        customerContact: json['customer_contact'] as String,
        note: json['note'] as String?,
        totalPrice: json['total_price'] as int,
        status: json['status'] as String,
        items: (json['items'] as List<dynamic>)
            .map((e) => OrderItemDetail.fromJson(e as Map<String, dynamic>))
            .toList(),
        paymentProof: json['payment_proof'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class OrderItemDetail {
  final String productName;
  final int quantity;
  final int price;

  OrderItemDetail({
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItemDetail.fromJson(Map<String, dynamic> json) => OrderItemDetail(
        productName: json['product_name'] as String,
        quantity: json['quantity'] as int,
        price: json['price'] as int,
      );
}