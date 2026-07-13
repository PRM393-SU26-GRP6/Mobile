import 'package:exe101/data/remote/map/geocoding_api_service.dart';
import 'package:exe101/domain/models/geocoding_result.dart';

abstract interface class GeocodingRepository {
  Future<GeocodingResult?> findAddress(String address);
}

class NominatimGeocodingRepository implements GeocodingRepository {
  NominatimGeocodingRepository({required this.apiService});

  final GeocodingApiService apiService;
  static final Map<String, GeocodingResult?> _cache = {};

  @override
  Future<GeocodingResult?> findAddress(String address) async {
    final cacheKey = address.trim().toLowerCase();
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey];

    GeocodingResult? result;
    final candidates = _buildSearchCandidates(address);
    for (var index = 0; index < candidates.length; index++) {
      final results = await apiService.search(candidates[index]);
      if (results.isEmpty) continue;
      result = index == 0 ? results.first : results.first.asApproximate();
      break;
    }
    _cache[cacheKey] = result;
    return result;
  }

  List<String> _buildSearchCandidates(String address) {
    final normalized = address.trim();
    final parts = normalized
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.length < 4) return [normalized];

    return [normalized, parts.skip(1).join(', ')];
  }
}
