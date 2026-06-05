import '../domain/booking_models.dart';

class VenuePage {
  const VenuePage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  final List<Venue> items;
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;
}

class VenueDetailData {
  const VenueDetailData({
    required this.venue,
    required this.fields,
    required this.slots,
    required this.reviews,
  });

  final Venue venue;
  final List<FieldInfo> fields;
  final List<SlotInfo> slots;
  final List<ReviewInfo> reviews;
}

class VenueReviewData {
  const VenueReviewData({
    required this.reviews,
    required this.totalCount,
    required this.averageRating,
    required this.page,
    required this.pageSize,
  });

  final List<ReviewInfo> reviews;
  final int totalCount;
  final double averageRating;
  final int page;
  final int pageSize;
}

class AmenityFilter {
  const AmenityFilter({required this.id, required this.name, this.icon = ''});

  factory AmenityFilter.fromJson(Map<String, dynamic> json) {
    return AmenityFilter(
      id: readString(json, 'amenityId'),
      name: readString(json, 'name'),
      icon: readString(json, 'icon'),
    );
  }

  final String id;
  final String name;
  final String icon;
}

class VenueApiException implements Exception {
  const VenueApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

T? read<T>(Map<String, dynamic> json, String key) {
  final pascalKey = key.isEmpty
      ? key
      : '${key[0].toUpperCase()}${key.substring(1)}';
  final value = json[key] ?? json[pascalKey];
  return value is T ? value : null;
}

String readString(Map<String, dynamic> json, String key) {
  final value = read<Object?>(json, key);
  return value?.toString() ?? '';
}
