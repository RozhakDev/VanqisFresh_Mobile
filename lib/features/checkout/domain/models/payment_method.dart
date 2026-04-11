class PaymentMethod {
  final int id;
  final String name;
  final String providerType;
  final String? accountNumber;
  final String? accountName;
  final String? qrCode;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.providerType,
    this.accountNumber,
    this.accountName,
    this.qrCode,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as int,
      name: json['name'] as String,
      providerType: json['provider_type'] as String,
      accountNumber: json['account_number'] as String?,
      accountName: json['account_name'] as String?,
      qrCode: json['qr_code'] as String?,
    );
  }
}

class StoreContact {
  final String platform;
  final String url;

  StoreContact({required this.platform, required this.url});

  factory StoreContact.fromJson(Map<String, dynamic> json) {
    return StoreContact(
      platform: json['platform'] as String,
      url: json['url'] as String,
    );
  }
}