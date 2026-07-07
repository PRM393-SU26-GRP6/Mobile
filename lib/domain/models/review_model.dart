class ReviewModel {
  final String reviewId;
  final String userId;
  final String? userName;
  final String venueId;
  final String? venueName;
  final String? bookingId;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  ReviewModel({
    required this.reviewId,
    required this.userId,
    required this.venueId,
    this.userName,
    this.venueName,
    this.bookingId,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      reviewId: json['reviewId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      venueId: json['venueId']?.toString() ?? '',
      userName: json['userName'] as String?,
      venueName: json['venueName'] as String?,
      bookingId: json['bookingId']?.toString(),
      rating: (json['rating'] is num) ? (json['rating'] as num).toInt() : 0,
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'].toString()),
    );
  }
}

class ReviewListResponse {
  final List<ReviewModel> reviews;
  final int totalCount;
  final double averageRating;
  final int page;
  final int pageSize;

  ReviewListResponse({
    required this.reviews,
    required this.totalCount,
    required this.averageRating,
    required this.page,
    required this.pageSize,
  });

  factory ReviewListResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['reviews'] ?? json['data'] ?? json['items'] ?? [];
    final list = raw is List ? raw : const [];
    return ReviewListResponse(
      reviews: list
          .map((e) => ReviewModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      totalCount:
          (json['totalCount'] is num) ? (json['totalCount'] as num).toInt() : 0,
      averageRating: (json['averageRating'] is num)
          ? (json['averageRating'] as num).toDouble()
          : 0.0,
      page: (json['page'] is num) ? (json['page'] as num).toInt() : 1,
      pageSize:
          (json['pageSize'] is num) ? (json['pageSize'] as num).toInt() : 5,
    );
  }

  bool get hasMore {
    if (pageSize <= 0) return false;
    return reviews.length + (page - 1) * pageSize < totalCount;
  }
}
