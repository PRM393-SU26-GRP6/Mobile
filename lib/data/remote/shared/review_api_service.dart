import 'package:dio/dio.dart';
import 'package:exe101/core/config/env.dart';
import 'package:exe101/data/remote/_base_api_service.dart';
import 'package:exe101/domain/models/review_model.dart';

/// All review endpoints.
///
/// Lazy lookups (per-booking, per-field):
/// - GET /api/v1/bookings/{id}/review
/// - GET /api/v1/reviews/field/{fieldId}/average-rating
///
/// Customer CRUD:
/// - GET  /api/v1/reviews/venue/{venueId}        (paginated)
/// - POST /api/v1/reviews
/// - GET  /api/v1/reviews/my-reviews
/// - PUT  /api/v1/reviews/{id}
/// - DELETE /api/v1/reviews/{id}
class ReviewApiService extends BaseApiService {
  ReviewApiService(super.dio);

  Map<String, dynamic> _unwrapData(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) return data;
      return raw;
    }
    return const <String, dynamic>{};
  }

  /// GET /api/v1/bookings/{id}/review
  /// Returns null when the booking has no review yet (404 / empty body).
  Future<BookingReviewDto?> getBookingReview(String bookingId) async {
    final headers = await authHeaders();
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '${Env.baseUrl}/api/v1/bookings/$bookingId/review',
        options: Options(headers: headers),
      );
      final code = response.statusCode ?? 0;
      if (code < 200 || code >= 300) return null;
      final data = _unwrapData(response.data);
      if (data.isEmpty || data['reviewId'] == null) return null;
      return BookingReviewDto.fromJson(data);
    } on DioException catch (e) {
      final code = e.response?.statusCode ?? 0;
      if (code == 404) return null;
      rethrow;
    }
  }

  /// GET /api/v1/reviews/field/{fieldId}/average-rating
  Future<FieldRatingDto> getFieldAverageRating(String fieldId) async {
    final headers = await authHeaders();
    final response = await dio.get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/reviews/field/$fieldId/average-rating',
      options: Options(headers: headers),
    );
    final data = _unwrapData(response.data);
    return FieldRatingDto.fromJson(data);
  }

  /// GET /api/v1/reviews/venue/{venueId}
  Future<ReviewListResponse> getReviewsByVenue({
    required String venueId,
    int page = 1,
    int pageSize = 5,
  }) async {
    final headers = await authHeaders();
    final response = await dio.get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/reviews/venue/$venueId',
      queryParameters: {
        'id': venueId,
        'page': page,
        'pageSize': pageSize,
      },
      options: Options(headers: headers),
    );

    if (response.data == null) {
      return ReviewListResponse(
        reviews: const [],
        totalCount: 0,
        averageRating: 0,
        page: page,
        pageSize: pageSize,
      );
    }

    final payload = response.data!['data'] ?? response.data;
    if (payload is! Map<String, dynamic>) {
      return ReviewListResponse(
        reviews: const [],
        totalCount: 0,
        averageRating: 0,
        page: page,
        pageSize: pageSize,
      );
    }

    return ReviewListResponse.fromJson(payload);
  }

  /// POST /api/v1/reviews
  Future<ReviewModel> createReview({
    required String venueId,
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    final headers = await authJsonHeaders();
    final response = await dio.post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/reviews',
      data: {
        'venueId': venueId,
        'bookingId': bookingId,
        'rating': rating,
        'comment': comment,
      },
      options: Options(headers: headers),
    );
    final data = response.data?['data'] ?? response.data ?? {};
    return ReviewModel.fromJson(data is Map<String, dynamic> ? data : {});
  }

  /// GET /api/v1/reviews/my-reviews
  Future<List<ReviewModel>> getMyReviews() async {
    final headers = await authHeaders();
    final response = await dio.get<dynamic>(
      '${Env.baseUrl}/api/v1/reviews/my-reviews',
      options: Options(headers: headers),
    );
    if (response.data == null) return [];
    final list = BaseApiService.extractList(response.data);
    return list
        .map((json) =>
            ReviewModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  /// PUT /api/v1/reviews/{id}
  Future<ReviewModel> updateReview({
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    final headers = await authJsonHeaders();
    final response = await dio.put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/reviews/$reviewId',
      data: {
        'rating': rating,
        'comment': comment,
      },
      options: Options(headers: headers),
    );
    final data = response.data?['data'] ?? response.data ?? {};
    return ReviewModel.fromJson(data is Map<String, dynamic> ? data : {});
  }

  /// DELETE /api/v1/reviews/{id}
  Future<void> deleteReview(String reviewId) async {
    final headers = await authHeaders();
    await dio.delete<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/reviews/$reviewId',
      options: Options(headers: headers),
    );
  }
}
