class BookingItemDto {
  final String bookingItemId;
  final String slotId;
  final String fieldId;
  final String? fieldName;
  final String venueId;
  final String? venueName;
  final DateTime startTime;
  final DateTime endTime;
  final double price;

  BookingItemDto({
    required this.bookingItemId,
    required this.slotId,
    required this.fieldId,
    this.fieldName,
    required this.venueId,
    this.venueName,
    required this.startTime,
    required this.endTime,
    required this.price,
  });

  factory BookingItemDto.fromJson(Map<String, dynamic> json) {
    return BookingItemDto(
      bookingItemId: json["bookingItemId"] ?? '',
      slotId: json["slotId"] ?? '',
      fieldId: json["fieldId"] ?? '',
      fieldName: json["fieldName"],
      venueId: json["venueId"] ?? '',
      venueName: json["venueName"],
      startTime: json["startTime"] != null
          ? DateTime.parse(json["startTime"])
          : DateTime.now(),
      endTime: json["endTime"] != null
          ? DateTime.parse(json["endTime"])
          : DateTime.now(),
      price: (json["price"] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PaymentDto {
  final String? paymentId;
  final double? amount;
  final String? paymentMethod;
  final String? paymentStatus;
  final DateTime? paidAt;

  PaymentDto({
    this.paymentId,
    this.amount,
    this.paymentMethod,
    this.paymentStatus,
    this.paidAt,
  });

  factory PaymentDto.fromJson(Map<String, dynamic> json) {
    return PaymentDto(
      paymentId: json["paymentId"],
      amount: (json["amount"] as num?)?.toDouble(),
      paymentMethod: json["paymentMethod"],
      paymentStatus: json["paymentStatus"],
      paidAt: json["paidAt"] != null ? DateTime.parse(json["paidAt"]) : null,
    );
  }
}

class BookingDto {
  final String id;
  final String userId;
  final String fieldId;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final double depositAmount;
  final double discountAmount;
  final String? bookingStatus;
  final String? note;
  final DateTime createdAt;
  final List<BookingItemDto>? items;
  final List<PaymentDto>? payments;

  BookingDto({
    required this.id,
    required this.userId,
    required this.fieldId,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.depositAmount,
    required this.discountAmount,
    this.bookingStatus,
    this.note,
    required this.createdAt,
    this.items,
    this.payments,
  });

  factory BookingDto.fromJson(Map<String, dynamic> json) {
    return BookingDto(
      id: json["id"] ?? '',
      userId: json["userId"] ?? '',
      fieldId: json["fieldId"] ?? '',
      startTime: json["startTime"] != null
          ? DateTime.parse(json["startTime"])
          : DateTime.now(),
      endTime: json["endTime"] != null
          ? DateTime.parse(json["endTime"])
          : DateTime.now(),
      totalPrice: (json["totalPrice"] as num?)?.toDouble() ?? 0.0,
      depositAmount: (json["depositAmount"] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json["discountAmount"] as num?)?.toDouble() ?? 0.0,
      bookingStatus: json["bookingStatus"],
      note: json["note"],
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : DateTime.now(),
      items: json["items"] != null
          ? (json["items"] as List)
              .map((e) => BookingItemDto.fromJson(e))
              .toList()
          : null,
      payments: json["payments"] != null
          ? (json["payments"] as List)
              .map((e) => PaymentDto.fromJson(e))
              .toList()
          : null,
    );
  }

  String get statusLabel {
    switch (bookingStatus?.toLowerCase()) {
      case 'pending':
        return 'Chờ duyệt';
      case 'accepted':
      case 'confirmed':
        return 'Đã xác nhận';
      case 'deposited':
        return 'Đã đặt cọc';
      case 'cancelled':
        return 'Đã hủy';
      case 'completed':
        return 'Hoàn thành';
      case 'rejected':
        return 'Từ chối';
      default:
        return bookingStatus ?? 'Không rõ';
    }
  }
}
