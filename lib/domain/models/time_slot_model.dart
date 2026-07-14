class TimeSlotDto {
  final String slotId;
  final String fieldId;
  final String startTime;
  final String endTime;
  final String selectedDate;
  final double price;
  final String? slotStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TimeSlotDto({
    required this.slotId,
    required this.fieldId,
    required this.startTime,
    required this.endTime,
    required this.selectedDate,
    required this.price,
    this.slotStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory TimeSlotDto.fromJson(Map<String, dynamic> json) => TimeSlotDto(
        slotId: json["slotId"]?.toString() ?? '',
        fieldId: json["fieldId"]?.toString() ?? '',
        startTime: json["startTime"]?.toString() ?? '',
        endTime: json["endTime"]?.toString() ?? '',
        selectedDate: json["selectedDate"]?.toString() ?? '',
        price: ((json["price"] as num?) ?? 0).toDouble(),
        slotStatus: json["slotStatus"]?.toString(),
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"].toString())
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.tryParse(json["updatedAt"].toString())
            : null,
      );

  factory TimeSlotDto.fromAvailableSlotJson(
    Map<String, dynamic> json, {
    required String fieldId,
    required String selectedDate,
  }) {
    return TimeSlotDto(
      slotId: json['slotId']?.toString() ?? '',
      fieldId: fieldId,
      startTime: _timeOfDay(json, 'startTimeOfDay', 'startTime'),
      endTime: _timeOfDay(json, 'endTimeOfDay', 'endTime'),
      selectedDate: selectedDate,
      price: ((json['price'] as num?) ?? 0).toDouble(),
      slotStatus: json['slotStatus']?.toString() ?? 'Available',
    );
  }

  TimeSlotDto copyWith({String? slotId}) {
    return TimeSlotDto(
      slotId: slotId ?? this.slotId,
      fieldId: fieldId,
      startTime: startTime,
      endTime: endTime,
      selectedDate: selectedDate,
      price: price,
      slotStatus: slotStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (slotId.isNotEmpty) 'slotId': slotId,
      if (fieldId.isNotEmpty) 'fieldId': fieldId,
      'startTime': startTime,
      'endTime': endTime,
      if (selectedDate.isNotEmpty) 'selectedDate': selectedDate,
      'price': price,
      if (slotStatus != null) 'slotStatus': slotStatus,
    };
  }

  String get timeRange => '$startTime - $endTime';

  /// Stable UI identity for schedule-generated slots that do not have a
  /// database ID until `/slots/lock` creates them.
  String get selectionKey =>
      slotId.isNotEmpty ? slotId : '$fieldId|$selectedDate|$startTime|$endTime';

  bool get isBooked =>
      slotStatus != null && (slotStatus == 'Booked' || slotStatus == 'booked');

  /// Slot thực sự có thể đặt được (không bị khoá, không bị đặt).
  bool get isAvailable {
    if (slotStatus == null) return true;
    final s = slotStatus!;
    return s == 'Available' || s == 'available';
  }

  bool get isLocked =>
      slotStatus != null && (slotStatus == 'Locked' || slotStatus == 'locked');

  bool get isPending =>
      slotStatus != null &&
      (slotStatus == 'Pending' || slotStatus == 'pending');

  static String _timeOfDay(
    Map<String, dynamic> json,
    String timeOfDayKey,
    String dateTimeKey,
  ) {
    final timeOfDay = json[timeOfDayKey]?.toString();
    if (timeOfDay != null && timeOfDay.isNotEmpty) return timeOfDay;

    final dateTime = DateTime.tryParse(json[dateTimeKey]?.toString() ?? '');
    if (dateTime == null) return '';
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class SlotLockResult {
  const SlotLockResult({required this.slotId, this.lockedUntil});

  final String slotId;
  final DateTime? lockedUntil;
}
