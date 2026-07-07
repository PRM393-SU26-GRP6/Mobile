import 'package:dio/dio.dart';
import 'package:exe101/core/config/env.dart';
import 'package:exe101/domain/models/review_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Read-only review lookup endpoints that complement the booking-scoped
/// review methods living in `api_service.dart`:
/// - GET /api/v1/bookings/{id}/review
/// - GET /api/v1/reviews/field/{fieldId}/average-rating
///
/// Both endpoints are used by lazy lookups (single booking, single field)
/// instead of fetching the whole list up front.
class ReviewApiService {
  final Dio dio;
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _keyAccessToken = 'access_token';

  ReviewApiService(this.dio);

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: _keyAccessToken);
    if (token == null || token.isEmpty) return {};
    return {'Authorization': 'Bearer $token'};
  }

  Map<String, dynamic> _unwrapData(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) return data;
      return raw;
    }
    return const {};
  }

  /// GET /api/v1/bookings/{id}/review
  /// Returns null when the booking has no review yet (404 / empty body).
  Future<BookingReviewDto?> getBookingReview(String bookingId) async {
    final headers = await _authHeaders();
    try {
      final response = await dio.get(
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
    final headers = await _authHeaders();
    final response = await dio.get(
      '${Env.baseUrl}/api/v1/reviews/field/$fieldId/average-rating',
      options: Options(headers: headers),
    );
    final data = _unwrapData(response.data);
    return FieldRatingDto.fromJson(data);
  }
}
