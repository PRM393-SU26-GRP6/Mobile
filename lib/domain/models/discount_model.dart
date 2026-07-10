class ValidateDiscountRequestDto {
  final String? code;
  final String? fieldId;
  final List<String>? slotIds;
  final double totalAmount;

  ValidateDiscountRequestDto({
    this.code,
    this.fieldId,
    this.slotIds,
    required this.totalAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      if (code != null) 'code': code,
      if (fieldId != null) 'fieldId': fieldId,
      if (slotIds != null) 'slotIds': slotIds,
      'totalAmount': totalAmount,
    };
  }
}

class ValidateDiscountResponseDto {
  final bool isValid;
  final String? message;
  final String? discountId;
  final double discountAmount;
  final double finalAmount;

  ValidateDiscountResponseDto({
    required this.isValid,
    this.message,
    this.discountId,
    required this.discountAmount,
    required this.finalAmount,
  });

  factory ValidateDiscountResponseDto.fromJson(Map<String, dynamic> json) {
    return ValidateDiscountResponseDto(
      isValid: json['isValid'] ?? false,
      message: json['message'],
      discountId: json['discountId'],
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (json['finalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DiscountDto {
  final String discountId;
  final String ownerId;
  final String? fieldId;
  final String? code;
  final String? name;
  final String? discountType;
  final double value;
  final double minBookingAmount;
  final double maxDiscountAmount;
  final int usageLimit;
  final int usedCount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  DiscountDto({
    required this.discountId,
    required this.ownerId,
    this.fieldId,
    this.code,
    this.name,
    this.discountType,
    required this.value,
    required this.minBookingAmount,
    required this.maxDiscountAmount,
    required this.usageLimit,
    required this.usedCount,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory DiscountDto.fromJson(Map<String, dynamic> json) {
    return DiscountDto(
      discountId: json['discountId'] ?? '',
      ownerId: json['ownerId'] ?? '',
      fieldId: json['fieldId'],
      code: json['code'],
      name: json['name'],
      discountType: json['discountType'],
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      minBookingAmount: (json['minBookingAmount'] as num?)?.toDouble() ?? 0.0,
      maxDiscountAmount: (json['maxDiscountAmount'] as num?)?.toDouble() ?? 0.0,
      usageLimit: json['usageLimit'] as int? ?? 0,
      usedCount: json['usedCount'] as int? ?? 0,
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'discountId': discountId,
      'ownerId': ownerId,
      if (fieldId != null) 'fieldId': fieldId,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (discountType != null) 'discountType': discountType,
      'value': value,
      'minBookingAmount': minBookingAmount,
      'maxDiscountAmount': maxDiscountAmount,
      'usageLimit': usageLimit,
      'usedCount': usedCount,
      'startDate': startDate.toUtc().toIso8601String(),
      'endDate': endDate.toUtc().toIso8601String(),
      'isActive': isActive,
    };
  }
}
