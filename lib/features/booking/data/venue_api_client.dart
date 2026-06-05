import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../domain/booking_models.dart';
import 'package:prm_web/features/booking/data/venue_api_mapper.dart';
import 'package:prm_web/features/booking/data/venue_api_models.dart';

class VenueApiClient {
  VenueApiClient({String? baseUrl, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: (baseUrl == null || baseUrl.isEmpty)
                  ? _defaultBaseUrl
                  : baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
              headers: const {'Content-Type': 'application/json'},
              validateStatus: (_) => true,
            ),
          );

  static String get _defaultBaseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) return configured;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5234/api/v1';
    }
    return 'http://localhost:5234/api/v1';
  }

  final Dio _dio;

  Future<VenuePage> getVenues({
    String? query,
    String? fieldType,
    String? amenityId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final params = <String, Object?>{
      'Page': page,
      'PageSize': pageSize,
      if (query != null && query.trim().isNotEmpty) 'Q': query.trim(),
      if (amenityId != null && amenityId.isNotEmpty) 'AmenityIds': amenityId,
    };
    if (fieldType != null) {
      params['FieldType'] = fieldType;
    }

    final response = await _dio.get<Object?>(
      '/Venues',
      queryParameters: params,
    );
    return _parseVenuePage(response, 'Could not load venues');
  }

  Future<VenuePage> searchVenues({
    required String query,
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get<Object?>(
      '/Venues/search',
      queryParameters: {'q': query, 'page': page, 'pageSize': pageSize},
    );
    return _parseVenuePage(response, 'Could not search venues');
  }

  Future<List<Venue>> getNearbyVenues({
    required double latitude,
    required double longitude,
    double radius = 5,
  }) async {
    final response = await _dio.get<Object?>(
      '/Venues/map/nearby',
      queryParameters: {'lat': latitude, 'lng': longitude, 'radius': radius},
    );
    final data = _dataFromResponse(response, 'Could not load nearby venues');
    final items = data is List ? data : const [];
    return items
        .whereType<Object?>()
        .map((item) => venueFromJson(asMap(item)))
        .toList();
  }

  Future<List<AmenityFilter>> getAmenities() async {
    final response = await _dio.get<Object?>('/amenities');
    final data = _dataFromResponse(response, 'Could not load amenities');
    final items = data is List ? data : const [];
    return items
        .whereType<Object?>()
        .map((item) => AmenityFilter.fromJson(asMap(item)))
        .where((item) => item.name.isNotEmpty)
        .toList();
  }

  Future<VenueDetailData> getVenueDetailData(String venueId) async {
    final results = await Future.wait<Object>([
      getVenueById(venueId),
      getVenueFields(venueId),
      getVenueAmenities(venueId),
      getVenueImages(venueId),
      getVenueReviews(venueId),
    ]);

    final venue = results[0] as Venue;
    final fields = results[1] as List<FieldInfo>;
    final amenities = results[2] as List<String>;
    final imageUrls = results[3] as List<String>;
    final reviewData = results[4] as VenueReviewData;

    return VenueDetailData(
      venue: venue.copyWith(
        fields: fields.isEmpty ? venue.fields : fields,
        amenities: amenities,
        imageUrls: imageUrls,
        reviews: reviewData.reviews,
        rating: reviewData.averageRating == 0
            ? venue.rating
            : reviewData.averageRating,
        reviewCount: reviewData.totalCount == 0
            ? venue.reviewCount
            : reviewData.totalCount,
      ),
      fields: fields,
      slots: const [],
      reviews: reviewData.reviews,
    );
  }

  Future<Venue> getVenueById(String venueId) async {
    final response = await _dio.get<Object?>('/Venues/$venueId');
    final data = _dataFromResponse(response, 'Could not load venue detail');
    return venueFromJson(asMap(data));
  }

  Future<List<FieldInfo>> getVenueFields(String venueId) async {
    final response = await _dio.get<Object?>('/Venues/$venueId/fields');
    final data = _dataFromResponse(response, 'Could not load venue fields');
    final items = data is List ? data : const [];
    return items
        .whereType<Object?>()
        .map((item) => fieldFromJson(asMap(item)))
        .where((field) => field.id.isNotEmpty)
        .toList();
  }

  Future<List<String>> getVenueAmenities(String venueId) async {
    final response = await _dio.get<Object?>('/Venues/$venueId/amenities');
    final data = _dataFromResponse(response, 'Could not load venue amenities');
    final items = data is List ? data : const [];
    return items
        .whereType<Object?>()
        .map((item) => readString(asMap(item), 'name'))
        .where((name) => name.isNotEmpty)
        .toList();
  }

  Future<List<String>> getVenueImages(String venueId) async {
    final response = await _dio.get<Object?>('/Venues/$venueId/images');
    final data = _dataFromResponse(response, 'Could not load venue images');
    final items = data is List ? data : const [];
    return items
        .whereType<Object?>()
        .map((item) => readString(asMap(item), 'imageUrl'))
        .where((url) => url.isNotEmpty)
        .toList();
  }

  Future<VenueReviewData> getVenueReviews(
    String venueId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get<Object?>(
      '/reviews/venue/$venueId',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final data = _dataFromResponse(response, 'Could not load venue reviews');
    final map = asMap(data);
    final items = read<Object?>(map, 'reviews') is List
        ? read<List<Object?>>(map, 'reviews')!
        : const <Object?>[];

    return VenueReviewData(
      reviews: items.map((item) => reviewFromJson(asMap(item))).toList(),
      totalCount: readInt(map, 'totalCount') ?? 0,
      averageRating: readDouble(map, 'averageRating') ?? 0,
      page: readInt(map, 'page') ?? page,
      pageSize: readInt(map, 'pageSize') ?? pageSize,
    );
  }

  Future<List<SlotInfo>> getFieldSlots({
    required String fieldId,
    required String date,
  }) async {
    final response = await _dio.get<Object?>(
      '/fields/$fieldId/slots',
      queryParameters: {'date': date},
    );
    final data = _dataFromResponse(response, 'Could not load field slots');
    final items = data is List ? data : const [];
    return items
        .whereType<Object?>()
        .map((item) => slotFromJson(asMap(item)))
        .where((slot) => slot.id.isNotEmpty)
        .toList();
  }

  VenuePage _parseVenuePage(
    Response<Object?> response,
    String fallbackMessage,
  ) {
    final data = _dataFromResponse(response, fallbackMessage);
    final map = asMap(data);
    final items = read<Object?>(map, 'items') is List
        ? read<List<Object?>>(map, 'items')!
        : const <Object?>[];

    return VenuePage(
      items: items.map((item) => venueFromJson(asMap(item))).toList(),
      page: readInt(map, 'page') ?? 1,
      pageSize: readInt(map, 'pageSize') ?? items.length,
      totalItems: readInt(map, 'totalItems') ?? items.length,
      totalPages: readInt(map, 'totalPages') ?? 1,
    );
  }

  Object? _dataFromResponse(
    Response<Object?> response,
    String fallbackMessage,
  ) {
    final json = asMap(_decodeResponse(response.data));
    final success = read<bool>(json, 'success') ?? false;
    if ((response.statusCode ?? 0) >= 200 &&
        (response.statusCode ?? 0) < 300 &&
        success) {
      return read<Object?>(json, 'data');
    }

    final message = read<String>(json, 'message');
    throw VenueApiException(
      message == null || message.isEmpty
          ? '$fallbackMessage. Status code: ${response.statusCode ?? 0}'
          : message,
    );
  }

  Object? _decodeResponse(Object? data) {
    if (data is String && data.trim().isNotEmpty) return jsonDecode(data);
    return data;
  }

  void dispose() {
    _dio.close(force: true);
  }
}
