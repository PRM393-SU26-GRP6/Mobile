class PaymentModel {
  final String id;
  final String bookingId;
  final double amount;
  final String paymentStatus;
  final String paymentType;
  final String? transactionCode;
  final String gateway;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.paymentStatus,
    required this.paymentType,
    this.transactionCode,
    required this.gateway,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json["id"] ?? '',
      bookingId: json["bookingId"] ?? '',
      amount: (json["amount"] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json["paymentStatus"] ?? '',
      paymentType: json["paymentType"] ?? '',
      transactionCode: json["transactionCode"],
      gateway: json["gateway"] ?? '',
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : DateTime.now(),
    );
  }
}

class BankInfoModel {
  final String bankId;
  final String accountNo;
  final String accountName;

  BankInfoModel({
    required this.bankId,
    required this.accountNo,
    required this.accountName,
  });

  factory BankInfoModel.fromJson(Map<String, dynamic> json) {
    return BankInfoModel(
      bankId: json["bankId"] ?? '',
      accountNo: json["accountNo"] ?? '',
      accountName: json["accountName"] ?? '',
    );
  }
}

class SePayQRInfoModel {
  final String paymentId;
  final double amount;
  final String description;
  final String status;
  final String qrUrl;
  final BankInfoModel? bankInfo;

  SePayQRInfoModel({
    required this.paymentId,
    required this.amount,
    required this.description,
    required this.status,
    required this.qrUrl,
    this.bankInfo,
  });

  factory SePayQRInfoModel.fromJson(Map<String, dynamic> json) {
    return SePayQRInfoModel(
      paymentId: json["paymentId"] ?? '',
      amount: (json["amount"] as num?)?.toDouble() ?? 0.0,
      description: json["description"] ?? '',
      status: json["status"] ?? '',
      qrUrl: json["qrUrl"] ?? '',
      bankInfo: json["bankInfo"] != null
          ? BankInfoModel.fromJson(json["bankInfo"])
          : null,
    );
  }
}
