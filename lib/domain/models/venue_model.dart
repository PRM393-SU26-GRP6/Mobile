class VenueModel {
  final String id;
  final String? venueName;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? description;
  final String? openingHours;
  final String? phoneContact;
  final double? averageRating;
  final int? totalReviews;
  final double? minPrice;
  final double? maxPrice;
  final List<String>? images;
  final List<AmenityModel>? amenities;
  final List<FootballFieldDto>? fields;
  final bool? isActive;
  final String? ownerId;
  final String? ownerName;

  VenueModel({
    required this.id,
    this.venueName,
    this.address,
    this.latitude,
    this.longitude,
    this.description,
    this.openingHours,
    this.phoneContact,
    this.averageRating,
    this.totalReviews,
    this.minPrice,
    this.maxPrice,
    this.images,
    this.amenities,
    this.fields,
    this.isActive,
    this.ownerId,
    this.ownerName,
  });

  factory VenueModel.fromJson(Map<String, dynamic> json) {
    String resolvedId = '';
    if (json["venueId"] != null && json["venueId"].toString().isNotEmpty) {
      resolvedId = json["venueId"].toString();
    } else if (json["id"] != null && json["id"].toString().isNotEmpty) {
      resolvedId = json["id"].toString();
    }

    List<String>? resolvedImages;
    if (json["images"] != null) {
      final imgList = json["images"] as List;
      if (imgList.isNotEmpty && imgList.first is String) {
        resolvedImages = List<String>.from(imgList);
      } else {
        resolvedImages = imgList
            .where((e) => e is Map && e["imageUrl"] != null)
            .map<String>((e) => e["imageUrl"].toString())
            .toList();
      }
    }

    return VenueModel(
      id: resolvedId,
      venueName: json["venueName"],
      address: json["address"],
      latitude: (json["latitude"] as num?)?.toDouble(),
      longitude: (json["longitude"] as num?)?.toDouble(),
      description: json["description"],
      openingHours: json["openingHours"],
      phoneContact: json["phoneContact"],
      averageRating: (json["averageRating"] as num?)?.toDouble(),
      totalReviews: json["totalReviews"] as int?,
      minPrice: (json["minPrice"] as num?)?.toDouble(),
      maxPrice: (json["maxPrice"] as num?)?.toDouble(),
      images: resolvedImages,
      amenities: json["amenities"] != null
          ? (json["amenities"] as List)
              .map((e) => AmenityModel.fromJson(e))
              .toList()
          : null,
      fields: json["fields"] != null
          ? (json["fields"] as List)
              .map((e) => FootballFieldDto.fromJson(e))
              .toList()
          : null,
      isActive: json["isActive"] as bool?,
      ownerId: json["ownerId"],
      ownerName: json["ownerName"],
    );
  }
}

class AmenityModel {
  final String? id;
  final String? amenityName;
  final String? icon;

  AmenityModel({this.id, this.amenityName, this.icon});

  factory AmenityModel.fromJson(Map<String, dynamic> json) => AmenityModel(
        id: json["amenityId"] ?? json["id"],
        amenityName: json["name"] ?? json["amenityName"],
        icon: json["icon"],
      );
}

class FootballFieldDto {
  final String id;
  final String? ownerId;
  final String? fieldName;
  final String? description;
  final String? fieldType;
  final String? location;
  final double? latitude;
  final double? longitude;
  final double? pricePerHour;
  final bool? isActive;

  FootballFieldDto({
    required this.id,
    this.ownerId,
    this.fieldName,
    this.description,
    this.fieldType,
    this.location,
    this.latitude,
    this.longitude,
    this.pricePerHour,
    this.isActive,
  });

  factory FootballFieldDto.fromJson(Map<String, dynamic> json) =>
      FootballFieldDto(
        id: json["id"] ?? '',
        ownerId: json["ownerId"],
        fieldName: json["fieldName"],
        description: json["description"],
        fieldType: json["fieldType"],
        location: json["location"],
        latitude: (json["latitude"] as num?)?.toDouble(),
        longitude: (json["longitude"] as num?)?.toDouble(),
        pricePerHour: (json["pricePerHour"] as num?)?.toDouble(),
        isActive: json["isActive"] as bool?,
      );

  String get fieldTypeLabel {
    switch (fieldType) {
      case 'FiveASide':
        return 'Sân 5';
      case 'SevenASide':
        return 'Sân 7';
      case 'ElevenASide':
        return 'Sân 11';
      default:
        return fieldType ?? 'Sân';
    }
  }
}
