/// Ảnh của venue do owner upload.
/// Backend có 2 endpoint:
/// - GET /api/v1/Venues/{id}/images
/// - POST /api/v1/owner/venues/{id}/images (multipart)
/// - DELETE /api/v1/owner/venues/{id}/images/{imageId}
class VenueImageDto {
  final String? id;
  final String? imageId;
  final String? imageUrl;
  final String? venueId;
  final int? displayOrder;
  final bool? isPrimary;
  final DateTime? createdAt;

  const VenueImageDto({
    this.id,
    this.imageId,
    this.imageUrl,
    this.venueId,
    this.displayOrder,
    this.isPrimary,
    this.createdAt,
  });

  /// Trả về id dùng cho API delete (BE path param {imageId}).
  String? get resolvedImageId {
    if (imageId != null && imageId!.isNotEmpty) return imageId;
    return id;
  }

  String get urlOrEmpty => imageUrl ?? '';

  factory VenueImageDto.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['imageId'] ?? json['venueImageId'];
    return VenueImageDto(
      id: rawId?.toString(),
      imageId: json['imageId']?.toString(),
      imageUrl:
          (json['imageUrl'] ?? json['url'] ?? json['image'] ?? json['src'])
              ?.toString(),
      venueId: json['venueId']?.toString(),
      displayOrder: (json['displayOrder'] as num?)?.toInt(),
      isPrimary: json['isPrimary'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
