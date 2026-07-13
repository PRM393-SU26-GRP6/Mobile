import 'package:dio/dio.dart';
import 'package:exe101/core/config/env.dart';
import 'package:exe101/data/remote/_base_api_service.dart';
import 'package:exe101/domain/models/venue_model.dart';

/// Customer-facing venue browse endpoints (public read paths).
/// Owner-side CRUD lives in `venue_owner_api_service.dart`.
class VenueApiService extends BaseApiService {
  VenueApiService(super.dio);

  /// GET /api/v1/Venues
  Future<List<VenueModel>> getVenues({
    String? q,
    String? fieldType,
    String? amenityIds,
    double? minRating,
    double? priceMin,
    double? priceMax,
    double? userLatitude,
    double? userLongitude,
    double? radiusInKm,
    String? sort,
    int page = 1,
    int pageSize = 20,
  }) async {
    final headers = await authHeaders();
    final params = <String, dynamic>{
      'Page': page,
      'PageSize': pageSize,
    };
    if (q != null) params['Q'] = q;
    if (fieldType != null) params['FieldType'] = fieldType;
    if (amenityIds != null) params['AmenityIds'] = amenityIds;
    if (minRating != null) params['MinRating'] = minRating;
    if (priceMin != null) params['PriceMin'] = priceMin;
    if (priceMax != null) params['PriceMax'] = priceMax;
    if (userLatitude != null) params['UserLatitude'] = userLatitude;
    if (userLongitude != null) params['UserLongitude'] = userLongitude;
    if (radiusInKm != null) params['RadiusInKm'] = radiusInKm;
    if (sort != null) params['Sort'] = sort;

    final response = await dio.get<dynamic>(
      '${Env.baseUrl}/api/v1/Venues',
      queryParameters: params,
      options: Options(headers: headers),
    );
    return _parseVenueList(response.data);
  }

  /// GET /api/v1/Venues/search
  Future<List<VenueModel>> searchVenues({
    String? q,
    int page = 1,
    int pageSize = 20,
  }) async {
    final headers = await authHeaders();
    final params = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (q != null && q.isNotEmpty) params['q'] = q;
    final response = await dio.get<dynamic>(
      '${Env.baseUrl}/api/v1/Venues/search',
      queryParameters: params,
      options: Options(headers: headers),
    );
    return _parseVenueList(response.data);
  }

  /// GET /api/v1/amenities
  Future<List<AmenityModel>> getAllAmenities() async {
    final response = await dio.get<dynamic>(
      '${Env.baseUrl}/api/v1/amenities',
    );
    if (response.data == null) return [];
    final list = BaseApiService.extractList(response.data);
    if (list.isEmpty && response.data is Map<String, dynamic>) {
      final inner = BaseApiService.extractList(
          (response.data as Map<String, dynamic>)['data']);
      if (inner.isNotEmpty) return _parseAmenities(inner);
    }
    return _parseAmenities(list);
  }

  /// GET /api/v1/Venues/{id}
  Future<VenueModel?> getVenueById(String id) async {
    final headers = await authHeaders();
    final response = await dio.get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/Venues/$id',
      options: Options(headers: headers),
    );
    if (response.data == null) return null;
    final venueData = BaseApiService.unwrapData(response.data);
    if (venueData.isEmpty) return null;

    final venue = VenueModel.fromJson(venueData);
    if (venue.images?.isNotEmpty == true) return venue;
    final imageUrls = await getVenueImageUrls(id);
    return imageUrls.isEmpty ? venue : venue.copyWith(images: imageUrls);
  }

  /// GET /api/v1/Venues/{id}/images
  Future<List<String>> getVenueImageUrls(String id) async {
    final response = await dio.get<dynamic>(
      '${Env.baseUrl}/api/v1/Venues/$id/images',
    );
    final images = BaseApiService.extractList(response.data);
    return images
        .map<String?>((image) {
          if (image is String) return image;
          if (image is Map && image['imageUrl'] != null) {
            return image['imageUrl'].toString();
          }
          return null;
        })
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .toList();
  }

  /// GET /api/v1/Venues/{id}/fields
  Future<List<FootballFieldDto>> getFieldsByVenue(String venueId) async {
    final headers = await authHeaders();
    final response = await dio.get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/Venues/$venueId/fields',
      options: Options(headers: headers),
    );
    if (response.data != null && response.data!['data'] != null) {
      final list = response.data!['data'];
      if (list is List) {
        return list.map((json) => FootballFieldDto.fromJson(json)).toList();
      }
    }
    return [];
  }

  // --- private parsers ---

  List<VenueModel> _parseVenueList(dynamic raw) {
    if (raw == null) return const [];
    final list = BaseApiService.extractList(raw);
    if (list.isEmpty && raw is Map<String, dynamic>) {
      final inner = BaseApiService.extractList(raw['data']);
      if (inner.isNotEmpty) {
        return inner
            .map((json) =>
                VenueModel.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();
      }
    }
    return list
        .map((json) =>
            VenueModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  List<AmenityModel> _parseAmenities(List<dynamic> list) {
    return list
        .map((json) =>
            AmenityModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }
}
