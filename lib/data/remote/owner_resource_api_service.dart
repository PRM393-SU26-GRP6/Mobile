import 'package:dio/dio.dart';

import 'package:exe101/core/config/env.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:exe101/domain/models/venue_image_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Owner-side booking/slot/image endpoints:
/// - GET    /api/v1/owner/bookings/{id}
/// - PUT    /api/v1/owner/slots/{id}
/// - DELETE /api/v1/owner/slots/{id}
/// - POST   /api/v1/owner/venues/{id}/images (multipart)
/// - DELETE /api/v1/owner/venues/{id}/images/{imageId}
class OwnerResourceApiService {
  final Dio dio;
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  OwnerResourceApiService(this.dio);

  static const _keyAccessToken = 'access_token';

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: _keyAccessToken);
    if (token == null || token.isEmpty) return {};
    return {'Authorization': 'Bearer $token'};
  }

  Future<BookingDto?> getOwnerBookingById(String bookingId) async {
    final headers = await _authHeaders();
    final response = await dio.get(
      '${Env.baseUrl}/api/v1/owner/bookings/$bookingId',
      options: Options(headers: headers),
    );

    final data = response.data;
    if (data == null) return null;
    if (data is! Map<String, dynamic>) return null;

    final payload = data['data'] ?? data;
    if (payload is! Map<String, dynamic>) return null;
    return BookingDto.fromJson(payload);
  }

  Future<TimeSlotDto> updateOwnerSlot(
    String slotId, {
    double? price,
    String? status,
  }) async {
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';

    final payload = <String, dynamic>{};
    if (price != null) payload['price'] = price;
    if (status != null) payload['slotStatus'] = status;

    final response = await dio.put(
      '${Env.baseUrl}/api/v1/owner/slots/$slotId',
      data: payload,
      options: Options(headers: headers),
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Invalid response from server',
      );
    }
    final payload2 = data['data'] ?? data;
    if (payload2 is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Invalid response body',
      );
    }
    return TimeSlotDto.fromJson(payload2);
  }

  Future<void> deleteOwnerSlot(String slotId) async {
    final headers = await _authHeaders();
    await dio.delete(
      '${Env.baseUrl}/api/v1/owner/slots/$slotId',
      options: Options(headers: headers),
    );
  }

  /// Lấy danh sách ảnh venue qua endpoint công khai.
  /// Swagger định nghĩa: GET /api/v1/Venues/{id}/images
  /// Response body là list image objects (hoặc list URL strings).
  /// Trả về list [VenueImageDto] đã parse, hoặc empty list nếu lỗi.
  Future<List<VenueImageDto>> getVenueImages(String venueId) async {
    final url = '${Env.baseUrl}/api/v1/Venues/$venueId/images';
    debugPrint('[OwnerResourceApi] getVenueImages: GET $url');
    try {
      final headers = await _authHeaders();
      debugPrint('[OwnerResourceApi] headers: $headers');
      final response = await dio.get(
        url,
        options: Options(headers: headers),
      );

      debugPrint(
          '[OwnerResourceApi] response.statusCode: ${response.statusCode}');
      debugPrint('[OwnerResourceApi] response.data: ${response.data}');

      if (response.data == null) return const [];
      return _parseImageList(response.data, venueId);
    } catch (e, stack) {
      debugPrint('[OwnerResourceApi] getVenueImages error: $e\n$stack');
      return const [];
    }
  }

  /// Parse list ảnh từ response body (BE có thể trả nhiều format).
  /// Hỗ trợ:
  /// - `{ "success": true, "data": [...] }` → format BE thật
  /// - `{ "data": { "image": [...] } }`    → nested data wrap
  /// - `{ "data": [...] }`                 → simple data wrap
  /// - `{ "image": [...] }` / `{ "images": [...] }` → object wrap
  /// - `[...]`                              → direct list
  List<VenueImageDto> _parseImageList(dynamic data, String venueId) {
    // Trường hợp BE wrap trong { success, data: [...] }
    if (data is Map) {
      final dataField = data['data'];
      if (dataField is Map) {
        final inner = dataField;
        final imageList =
            inner['image'] ?? inner['images'] ?? inner['data'] ?? inner;
        if (imageList is List) {
          return _parseFlatList(imageList, venueId);
        }
      }
      if (dataField is List) {
        return _parseFlatList(dataField, venueId);
      }
      // { "image": [...] } hoặc { "images": [...] } trực tiếp
      final directList =
          data['image'] ?? data['images'] ?? data['data'] ?? data['urls'];
      if (directList is List) {
        return _parseFlatList(directList, venueId);
      }
    }
    // Trường hợp BE trả thẳng list
    if (data is List) {
      return _parseFlatList(data, venueId);
    }
    return const [];
  }

  List<VenueImageDto> _parseFlatList(List<dynamic> list, String venueId) {
    return list.asMap().entries.map((entry) {
      final item = entry.value;
      if (item is String) {
        return VenueImageDto(imageUrl: item, venueId: venueId);
      }
      if (item is Map) {
        return VenueImageDto.fromJson(
            Map<String, dynamic>.from(item as Map<Object?, Object?>));
      }
      return VenueImageDto(venueId: venueId);
    }).toList();
  }

  /// Upload nhiều ảnh cùng lúc qua multipart.
  /// Trả về list URL ảnh nếu backend trả về trong body, nếu không sẽ null.
  Future<List<String>?> uploadVenueImages({
    required String venueId,
    required List<XFile> files,
  }) async {
    final headers = await _authHeaders();
    headers.remove('Content-Type'); // boundary managed by Dio

    final formData = FormData();
    for (final file in files) {
      // Đọc bytes để cross-platform (web + mobile)
      final bytes = await file.readAsBytes();
      final fileName = file.name;
      formData.files.add(
        MapEntry(
          'images',
          MultipartFile.fromBytes(
            bytes,
            filename: fileName,
          ),
        ),
      );
    }

    debugPrint(
        '[OwnerResourceApi] uploadVenueImages: POST /api/v1/owner/venues/$venueId/images');
    final response = await dio.post(
      '${Env.baseUrl}/api/v1/owner/venues/$venueId/images',
      data: formData,
      options: Options(
        headers: headers,
        sendTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
      ),
    );

    debugPrint(
        '[OwnerResourceApi] upload response.statusCode: ${response.statusCode}');
    debugPrint('[OwnerResourceApi] upload response.data: ${response.data}');

    if (response.statusCode != null && response.statusCode! >= 400) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Upload ảnh thất bại',
      );
    }
    return _extractUrls(response.data);
  }

  Future<void> deleteVenueImage({
    required String venueId,
    required String imageId,
  }) async {
    final headers = await _authHeaders();
    await dio.delete(
      '${Env.baseUrl}/api/v1/owner/venues/$venueId/images/$imageId',
      options: Options(headers: headers),
    );
  }

  /// Cố gắng parse list URL ảnh từ response body (nếu BE trả về).
  /// Hỗ trợ: `List<String>`, `List<Map>` có key `imageUrl` hoặc `url`,
  /// hoặc `Map` có key `urls`/`images`/`data`/`items`.
  List<String>? _extractUrls(dynamic raw) {
    if (raw == null) return null;
    if (raw is List) {
      return raw
          .map<String?>((e) {
            if (e is String) return e;
            if (e is Map && e['imageUrl'] != null) {
              return e['imageUrl'].toString();
            }
            if (e is Map && e['url'] != null) return e['url'].toString();
            return null;
          })
          .whereType<String>()
          .toList();
    }
    if (raw is Map) {
      for (final key in const ['urls', 'images', 'data', 'items']) {
        final v = raw[key];
        if (v is List) return _extractUrls(v);
      }
    }
    return null;
  }
}
