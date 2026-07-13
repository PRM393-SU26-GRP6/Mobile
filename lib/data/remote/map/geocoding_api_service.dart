import 'dart:async';

import 'package:dio/dio.dart';
import 'package:exe101/domain/models/geocoding_result.dart';
import 'package:flutter/foundation.dart';

class GeocodingApiService {
  GeocodingApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: const String.fromEnvironment(
                  'GEOCODING_BASE_URL',
                  defaultValue: 'https://nominatim.openstreetmap.org',
                ),
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  final Dio _dio;
  static Future<void> _requestQueue = Future.value();
  static DateTime? _lastRequestAt;

  Future<List<GeocodingResult>> search(String query) {
    final operation = _requestQueue.then((_) => _searchAfterRateLimit(query));
    _requestQueue = operation.then<void>((_) {}, onError: (_) {});
    return operation;
  }

  Future<List<GeocodingResult>> _searchAfterRateLimit(String query) async {
    final lastRequestAt = _lastRequestAt;
    if (lastRequestAt != null) {
      final remaining =
          const Duration(seconds: 1) - DateTime.now().difference(lastRequestAt);
      if (!remaining.isNegative) await Future<void>.delayed(remaining);
    }
    _lastRequestAt = DateTime.now();

    final response = await _dio.get<List<dynamic>>(
      '/search',
      queryParameters: {
        'q': query,
        'format': 'jsonv2',
        'limit': 5,
        'countrycodes': 'vn',
        'addressdetails': 1,
        'accept-language': 'vi',
      },
      options: Options(
        headers: kIsWeb
            ? null
            : const {
                'User-Agent':
                    'PitchBook-Mobile/1.0 (+https://api-prm-be.novaproj.site)',
              },
      ),
    );

    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(GeocodingResult.fromJson)
        .toList(growable: false);
  }
}
