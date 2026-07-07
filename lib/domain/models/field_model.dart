class FieldModel {
  final String? id;
  final String? venueId;
  final String? fieldName;
  final String? description;
  final String? fieldType;
  final double? priceMorning;
  final double? priceAfternoon;
  final double? priceEvening;
  final double? pricePerHour;
  final List<String>? amenities;
  final bool? isActive;
  final List<String>? images;

  FieldModel({
    this.id,
    this.venueId,
    this.fieldName,
    this.description,
    this.fieldType,
    this.priceMorning,
    this.priceAfternoon,
    this.priceEvening,
    this.pricePerHour,
    this.amenities,
    this.isActive,
    this.images,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      id: json['id'] ?? json['fieldId'],
      venueId: json['venueId'],
      fieldName: json['fieldName'],
      description: json['description'],
      fieldType: json['fieldType'],
      priceMorning: (json['priceMorning'] as num?)?.toDouble(),
      priceAfternoon: (json['priceAfternoon'] as num?)?.toDouble(),
      priceEvening: (json['priceEvening'] as num?)?.toDouble(),
      pricePerHour: (json['pricePerHour'] as num?)?.toDouble(),
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : null,
      isActive: json['isActive'] as bool?,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (venueId != null) 'venueId': venueId,
      'fieldName': fieldName,
      'description': description,
      'fieldType': fieldType,
      'priceMorning': priceMorning,
      'priceAfternoon': priceAfternoon,
      'priceEvening': priceEvening,
      'pricePerHour': pricePerHour,
      'amenities': amenities,
      'isActive': isActive ?? true,
      'images': images,
    };
  }

  static const List<String> fieldTypes = [
    'FiveASide',
    'SevenASide',
    'ElevenASide',
  ];

  static const Map<String, String> fieldTypeLabels = {
    'FiveASide': 'Sân 5 người',
    'SevenASide': 'Sân 7 người',
    'ElevenASide': 'Sân 11 người',
  };

  static const List<String> availableAmenities = [
    'Đèn chiếu sáng',
    'Nước uống',
    'WiFi',
    'Mái che',
    'Phòng thay đồ',
    'Căng tin',
    'Bãi đỗ xe',
    'Khu vực giải lao',
  ];
}
