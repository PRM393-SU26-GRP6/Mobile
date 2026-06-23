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
        slotId: json["slotId"] ?? '',
        fieldId: json["fieldId"] ?? '',
        startTime: json["startTime"] ?? '',
        endTime: json["endTime"] ?? '',
        selectedDate: json["selectedDate"] ?? '',
        price: (json["price"] as num).toDouble(),
        slotStatus: json["slotStatus"],
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.parse(json["updatedAt"])
            : null,
      );

  String get timeRange => '$startTime - $endTime';

  bool get isBooked =>
      slotStatus != null &&
      (slotStatus == 'Booked' || slotStatus == 'booked');

  bool get isAvailable => !isBooked;

  bool get isLocked =>
      slotStatus != null &&
      (slotStatus == 'Locked' || slotStatus == 'locked');

  bool get isPending =>
      slotStatus != null &&
      (slotStatus == 'Pending' || slotStatus == 'pending');
}
