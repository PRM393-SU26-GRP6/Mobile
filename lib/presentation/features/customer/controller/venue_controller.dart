import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:get/get.dart';

class VenueController extends GetxController {
  VenueController({required this.apiService});

  final ApiService apiService;
  final venues = <VenueModel>[].obs;
  final allAmenities = <AmenityModel>[].obs;
  final amenitiesError = ''.obs;
  final isLoading = false.obs;
  final error = ''.obs;
  final searchQuery = ''.obs;
  final selectedAmenityIds = <String>[].obs;
  final page = 1.obs;
  final int pageSize = 5;
  final hasMore = true.obs;
  final isLoadingMore = false.obs;

  ApiServiceImpl? get _service =>
      apiService is ApiServiceImpl ? apiService as ApiServiceImpl : null;

  @override
  void onInit() {
    super.onInit();
    loadAmenities();
    loadVenues();
    debounce(searchQuery, (_) => loadVenues(),
        time: const Duration(milliseconds: 500));
  }

  Future<void> loadAmenities() async {
    try {
      amenitiesError.value = '';
      final service = _service;
      if (service != null) {
        allAmenities.assignAll(await service.getAllAmenities());
      }
    } catch (_) {
      amenitiesError.value = 'Không thể tải bộ lọc tiện ích';
    }
  }

  void toggleAmenityFilter(String amenityId) {
    selectedAmenityIds.contains(amenityId)
        ? selectedAmenityIds.remove(amenityId)
        : selectedAmenityIds.add(amenityId);
    loadVenues();
  }

  Future<void> loadVenues({bool reset = true}) async {
    final service = _service;
    if (service == null) return;
    if (reset) {
      page.value = 1;
      hasMore.value = true;
      venues.clear();
    }

    try {
      page.value == 1 ? isLoading.value = true : isLoadingMore.value = true;
      error.value = '';
      final amenities =
          selectedAmenityIds.isEmpty ? null : selectedAmenityIds.join(',');
      final fetched = await service.getVenues(
        q: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        amenityIds: amenities,
        page: page.value,
        pageSize: pageSize,
      );

      page.value == 1 ? venues.assignAll(fetched) : venues.addAll(fetched);
      hasMore.value = fetched.length == pageSize;
    } catch (e) {
      error.value = 'Không thể tải danh sách sân';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value) return;
    page.value += 1;
    await loadVenues(reset: false);
  }

  Future<void> refreshVenues() => loadVenues();

  void search(String query) {
    searchQuery.value = query.trim();
  }
}
