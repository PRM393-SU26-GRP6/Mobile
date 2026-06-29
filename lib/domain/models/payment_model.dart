enum PaymentMethod {
  cash,
  moMo,
  vnPay,
  sePay;

  String get value {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.moMo:
        return 'MoMo';
      case PaymentMethod.vnPay:
        return 'VNPay';
      case PaymentMethod.sePay:
        return 'SePay';
    }
  }

  static PaymentMethod fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'cash':
        return PaymentMethod.cash;
      case 'momo':
        return PaymentMethod.moMo;
      case 'vnpay':
        return PaymentMethod.vnPay;
      case 'sepay':
        return PaymentMethod.sePay;
      default:
        return PaymentMethod.sePay;
    }
  }
}

class PaymentModel {
  final String id;
  final String bookingId;
  final double amount;
  final String paymentStatus;
  final String paymentType;
  final PaymentMethod paymentMethod;
  final String? transactionCode;
  final DateTime? paidAt;
  final String? paymentUrl;
  final String? bookingStatus;
  final String gateway;
  final String? gatewayTransactionId;
  final String? gatewayReferenceCode;
  final String? gatewayAccountNumber;
  final String? gatewayDescription;
  final String? transactionDate;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.paymentStatus,
    required this.paymentType,
    required this.paymentMethod,
    this.transactionCode,
    this.paidAt,
    this.paymentUrl,
    this.bookingStatus,
    required this.gateway,
    this.gatewayTransactionId,
    this.gatewayReferenceCode,
    this.gatewayAccountNumber,
    this.gatewayDescription,
    this.transactionDate,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json["id"] ?? '',
      bookingId: json["bookingId"] ?? '',
      amount: (json["amount"] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json["paymentStatus"] ?? '',
      paymentType: json["paymentType"] ?? '',
      paymentMethod: PaymentMethod.fromString(json["paymentMethod"]),
      transactionCode: json["transactionCode"],
      paidAt: json["paidAt"] != null ? DateTime.tryParse(json["paidAt"]) : null,
      paymentUrl: json["paymentUrl"],
      bookingStatus: json["bookingStatus"],
      gateway: json["gateway"] ?? '',
      gatewayTransactionId: json["gatewayTransactionId"],
      gatewayReferenceCode: json["gatewayReferenceCode"],
      gatewayAccountNumber: json["gatewayAccountNumber"],
      gatewayDescription: json["gatewayDescription"],
      transactionDate: json["transactionDate"],
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : DateTime.now(),
    );
  }

  bool get isSuccess => paymentStatus.toLowerCase() == 'success' || paymentStatus.toLowerCase() == 'completed';
  bool get isPending => paymentStatus.toLowerCase() == 'pending' || paymentStatus.toLowerCase() == 'processing';
  bool get isFailed => paymentStatus.toLowerCase() == 'failed' || paymentStatus.toLowerCase() == 'error';
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

class SePayCheckoutFormModel {
  final String? payUrl;
  final String? merchant;
  final String? operation;
  final String? paymentMethod;
  final String? orderAmount;
  final String? currency;
  final String? orderInvoiceNumber;
  final String? orderDescription;
  final String? customerId;
  final String? successUrl;
  final String? errorUrl;
  final String? cancelUrl;
  final String? signature;

  SePayCheckoutFormModel({
    this.payUrl,
    this.merchant,
    this.operation,
    this.paymentMethod,
    this.orderAmount,
    this.currency,
    this.orderInvoiceNumber,
    this.orderDescription,
    this.customerId,
    this.successUrl,
    this.errorUrl,
    this.cancelUrl,
    this.signature,
  });

  factory SePayCheckoutFormModel.fromJson(Map<String, dynamic> json) {
    return SePayCheckoutFormModel(
      payUrl: json["payUrl"],
      merchant: json["merchant"],
      operation: json["operation"],
      paymentMethod: json["payment_method"],
      orderAmount: json["order_amount"]?.toString(),
      currency: json["currency"],
      orderInvoiceNumber: json["order_invoice_number"],
      orderDescription: json["order_description"],
      customerId: json["customer_id"],
      successUrl: json["success_url"],
      errorUrl: json["error_url"],
      cancelUrl: json["cancel_url"],
      signature: json["signature"],
    );
  }
}
