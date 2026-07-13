import 'package:exe101/domain/repositories/geocoding_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class VenueLocationPickerController extends GetxController {
  VenueLocationPickerController({required this.geocodingRepository});

  static const fallback = LatLng(10.7769, 106.7009);

  final GeocodingRepository geocodingRepository;
  final searchController = TextEditingController();
  final selectedLocation = fallback.obs;
  final isSearching = false.obs;
  final searchMessage = ''.obs;
  final searchSucceeded = false.obs;
  bool _initialized = false;
  int _searchGeneration = 0;

  void initialize(Object? arguments) {
    if (_initialized) return;
    _initialized = true;

    if (arguments is! Map) return;
    final latitude = (arguments['latitude'] as num?)?.toDouble();
    final longitude = (arguments['longitude'] as num?)?.toDouble();
    final address = arguments['address']?.toString().trim() ?? '';
    searchController.text = address;

    if (_isValidCoordinate(latitude, longitude)) {
      selectedLocation.value = LatLng(latitude!, longitude!);
    }
  }

  Future<void> searchInitialAddress() async {
    if (searchController.text.trim().isEmpty) return;
    await searchAddress();
  }

  Future<void> searchAddress() async {
    final query = searchController.text.trim();
    if (query.isEmpty || isSearching.value) return;

    final generation = ++_searchGeneration;
    isSearching.value = true;
    searchMessage.value = '';
    try {
      final result = await geocodingRepository.findAddress(query);
      if (generation != _searchGeneration) return;
      if (result == null) {
        searchSucceeded.value = false;
        searchMessage.value =
            'Không tìm thấy địa chỉ. Hãy nhập chi tiết hơn hoặc chạm bản đồ để chọn.';
        return;
      }

      selectedLocation.value = LatLng(result.latitude, result.longitude);
      searchSucceeded.value = true;
      searchMessage.value = result.isApproximate
          ? 'Kết quả gần đúng: ${result.displayName}. Hãy chỉnh marker nếu cần.'
          : result.displayName;
    } catch (_) {
      if (generation != _searchGeneration) return;
      searchSucceeded.value = false;
      searchMessage.value =
          'Không thể tìm địa chỉ lúc này. Bạn vẫn có thể chọn trực tiếp trên bản đồ.';
    } finally {
      if (generation == _searchGeneration) isSearching.value = false;
    }
  }

  void selectManually(LatLng location) {
    _searchGeneration++;
    isSearching.value = false;
    selectedLocation.value = location;
    searchSucceeded.value = true;
    searchMessage.value = 'Đã chọn vị trí trực tiếp trên bản đồ.';
  }

  bool _isValidCoordinate(double? latitude, double? longitude) {
    return latitude != null &&
        longitude != null &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180 &&
        !(latitude == 0 && longitude == 0);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
