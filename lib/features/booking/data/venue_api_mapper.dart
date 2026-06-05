import 'package:prm_web/features/booking/data/venue_api_models.dart';
import 'package:prm_web/features/booking/domain/booking_models.dart';

Venue venueFromJson(Map<String, dynamic> json) {
  final minPrice = readInt(json, 'minPrice') ?? 0;
  final maxPrice = readInt(json, 'maxPrice') ?? minPrice;
  final fields = readList(json, 'fields')
      .map((item) => fieldFromJson(asMap(item)))
      .where((field) => field.id.isNotEmpty)
      .toList();
  final amenities = readList(json, 'amenities')
      .map((item) => readString(asMap(item), 'name'))
      .where((name) => name.isNotEmpty)
      .toList();
  final images = readList(json, 'images')
      .map((item) => readString(asMap(item), 'imageUrl'))
      .where((url) => url.isNotEmpty)
      .toList();

  return Venue(
    id: readString(json, 'venueId'),
    name: readString(json, 'venueName'),
    address: readString(json, 'address'),
    rating: readDouble(json, 'averageRating') ?? 0,
    reviewCount: readInt(json, 'totalReviews') ?? 0,
    priceFrom: minPrice,
    priceTo: maxPrice,
    types: fields.map((field) => field.type).toSet().toList(),
    amenities: amenities,
    openHours: readString(json, 'openingHours'),
    fields: fields.isEmpty
        ? [
            FieldInfo(
              id: '${readString(json, 'venueId')}-default-field',
              name: 'Sân mặc định',
              type: '5',
              price: minPrice,
            ),
          ]
        : fields,
    imageUrls: images,
    latitude: readDouble(json, 'latitude'),
    longitude: readDouble(json, 'longitude'),
    distance: readDouble(json, 'distance'),
  );
}

FieldInfo fieldFromJson(Map<String, dynamic> json) {
  return FieldInfo(
    id: readString(json, 'id'),
    name: readString(json, 'fieldName'),
    type: fieldTypeLabel(readString(json, 'fieldType')),
    price: readInt(json, 'pricePerHour') ?? 0,
  );
}

SlotInfo slotFromJson(Map<String, dynamic> json) {
  final startTime = readDateTime(json, 'startTime');
  final endTime = readDateTime(json, 'endTime');
  return SlotInfo(
    id: readString(json, 'slotId'),
    time: timeRange(startTime, endTime),
    status: slotStatus(readString(json, 'slotStatus')),
  );
}

ReviewInfo reviewFromJson(Map<String, dynamic> json) {
  final userName = readString(json, 'userName');
  return ReviewInfo(
    id: readString(json, 'reviewId'),
    userName: userName.isEmpty ? 'Người dùng' : userName,
    rating: readInt(json, 'rating') ?? 0,
    comment: readString(json, 'comment'),
    createdAt: readDateTime(json, 'createdAt'),
  );
}

Map<String, dynamic> asMap(Object? data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return {};
}

List<Object?> readList(Map<String, dynamic> json, String key) {
  final value = read<Object?>(json, key);
  return value is List ? value : const [];
}

int? readInt(Map<String, dynamic> json, String key) {
  final value = read<Object?>(json, key);
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '');
}

double? readDouble(Map<String, dynamic> json, String key) {
  final value = read<Object?>(json, key);
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

DateTime? readDateTime(Map<String, dynamic> json, String key) {
  final value = read<Object?>(json, key);
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '');
}

String fieldTypeLabel(String fieldType) {
  return switch (fieldType) {
    'FiveASide' => '5',
    'SevenASide' => '7',
    'ElevenASide' => '11',
    '5' => '5',
    '7' => '7',
    '11' => '11',
    _ => fieldType.isEmpty ? '5' : fieldType,
  };
}

SlotStatus slotStatus(String status) {
  return switch (status.toLowerCase()) {
    'locked' => SlotStatus.locked,
    'booked' => SlotStatus.booked,
    _ => SlotStatus.available,
  };
}

String timeRange(DateTime? start, DateTime? end) {
  if (start == null || end == null) return '';
  return '${hhmm(start)} - ${hhmm(end)}';
}

String hhmm(DateTime dateTime) {
  final local = dateTime.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
