class FieldScheduleDto {
  final String? scheduleId;
  final String? fieldId;
  final int dayOfWeek;
  final String? openTime;
  final String? closeTime;
  final int slotDurationMinutes;
  final bool isActive;

  FieldScheduleDto({
    this.scheduleId,
    this.fieldId,
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    this.slotDurationMinutes = 60,
    this.isActive = true,
  });

  factory FieldScheduleDto.fromJson(Map<String, dynamic> json) {
    return FieldScheduleDto(
      scheduleId: json['scheduleId'],
      fieldId: json['fieldId'],
      dayOfWeek: json['dayOfWeek'] ?? 1,
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      slotDurationMinutes: json['slotDurationMinutes'] ?? 60,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduleId': scheduleId,
      'fieldId': fieldId,
      'dayOfWeek': dayOfWeek,
      'openTime': openTime,
      'closeTime': closeTime,
      'slotDurationMinutes': slotDurationMinutes,
      'isActive': isActive,
    };
  }

  FieldScheduleDto copyWith({
    String? scheduleId,
    String? fieldId,
    int? dayOfWeek,
    String? openTime,
    String? closeTime,
    int? slotDurationMinutes,
    bool? isActive,
  }) {
    return FieldScheduleDto(
      scheduleId: scheduleId ?? this.scheduleId,
      fieldId: fieldId ?? this.fieldId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      slotDurationMinutes: slotDurationMinutes ?? this.slotDurationMinutes,
      isActive: isActive ?? this.isActive,
    );
  }

  static const List<String> dayNames = [
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
    'Chủ nhật',
  ];

  String get dayName {
    if (dayOfWeek >= 1 && dayOfWeek <= 7) {
      return dayNames[dayOfWeek - 1];
    }
    return 'Ngày $dayOfWeek';
  }
}

class FieldScheduleRowDto {
  final int dayOfWeek;
  final String? openTime;
  final String? closeTime;
  final int slotDurationMinutes;
  final bool isActive;

  FieldScheduleRowDto({
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    this.slotDurationMinutes = 60,
    this.isActive = true,
  });

  factory FieldScheduleRowDto.fromJson(Map<String, dynamic> json) {
    return FieldScheduleRowDto(
      dayOfWeek: json['dayOfWeek'] ?? 1,
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      slotDurationMinutes: json['slotDurationMinutes'] ?? 60,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'openTime': openTime,
      'closeTime': closeTime,
      'slotDurationMinutes': slotDurationMinutes,
      'isActive': isActive,
    };
  }
}

class BulkCreateSlotsDto {
  final DateTime fromDate;
  final DateTime toDate;
  final String? startTime;
  final String? endTime;
  final int slotDurationMinutes;
  final double price;

  BulkCreateSlotsDto({
    required this.fromDate,
    required this.toDate,
    this.startTime,
    this.endTime,
    this.slotDurationMinutes = 60,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromDate': fromDate.toIso8601String(),
      'toDate': toDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'slotDurationMinutes': slotDurationMinutes,
      'price': price,
    };
  }
}
