import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:get/get.dart';

class VenueController extends GetxController {
  final ApiService apiService;

  final venues = <VenueModel>[].obs;
  final allAmenities = <AmenityModel>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;
  final searchQuery = ''.obs;
  final selectedAmenityIds = <String>[].obs;
  final page = 1.obs;
  final int pageSize = 5;
  final hasMore = true.obs;
  final isLoadingMore = false.obs;

  VenueController({required this.apiService});

  @override
  void onInit() {
    super.onInit();
    loadAmenities();
    loadVenues();
  }

  Future<void> loadAmenities() async {
    if (apiService is ApiServiceImpl) {
      try {
        final list = await (apiService as ApiServiceImpl).getAllAmenities();
        allAmenities.value = list;
      } catch (_) {}
    }
  }

  void toggleAmenityFilter(String amenityId) {
    if (selectedAmenityIds.contains(amenityId)) {
      selectedAmenityIds.remove(amenityId);
    } else {
      selectedAmenityIds.add(amenityId);
    }
    loadVenues();
  }

  Future<void> loadVenues({bool reset = true}) async {
    if (reset) {
      page.value = 1;
      hasMore.value = true;
      venues.clear();
    }

    try {
      if (page.value == 1) {
        isLoading.value = true;
        error.value = '';
      } else {
        isLoadingMore.value = true;
      }

      if (apiService is ApiServiceImpl) {
        final svc = apiService as ApiServiceImpl;
        final amenitiesParam = selectedAmenityIds.isNotEmpty
            ? selectedAmenityIds.join(',')
            : null;
            
        List<VenueModel> fetched = [];
        if (searchQuery.value.isNotEmpty) {
          fetched = await svc.searchVenues(
            q: searchQuery.value,
            page: page.value,
            pageSize: pageSize,
          );
        } else {
          fetched = await svc.getVenues(
            amenityIds: amenitiesParam,
            page: page.value,
            pageSize: pageSize,
          );
        }

        if (page.value == 1) {
          venues.value = fetched;
        } else {
          venues.addAll(fetched);
        }

        if (fetched.length < pageSize) {
          hasMore.value = false;
        } else {
          hasMore.value = true;
        }

        // BE GET /Venues list không trả `images` trong mỗi item; chỉ GET /Venues/{id} mới có.
        // Sau khi có list, gọi song song getVenueById cho từng venue để merge ảnh.
        await _enrichVenuesWithImages(fetched);
      }
    } catch (e) {
      error.value = 'Có lỗi xảy ra: $e';
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

  Future<void> refreshVenues() async {
    await loadVenues();
  }

  /// Gọi song song `GET /Venues/{id}` để lấy `images` cho mỗi venue trong list.
  /// Vì API list không trả images, cần enrich từ detail endpoint.
  Future<void> _enrichVenuesWithImages(List<VenueModel> target) async {
    if (target.isEmpty || apiService is! ApiServiceImpl) return;
    final svc = apiService as ApiServiceImpl;

    final results = await Future.wait(
      target.map((v) async {
        try {
          return await svc.getVenueById(v.id);
        } catch (_) {
          return null;
        }
      }),
    );

    for (var i = 0; i < target.length; i++) {
      final detailed = results[i];
      if (detailed == null) continue;
      if ((target[i].images == null || target[i].images!.isEmpty) &&
          detailed.images != null &&
          detailed.images!.isNotEmpty) {
        final updated = VenueModel(
          id: target[i].id,
          venueName: target[i].venueName ?? detailed.venueName,
          address: target[i].address ?? detailed.address,
          latitude: target[i].latitude ?? detailed.latitude,
          longitude: target[i].longitude ?? detailed.longitude,
          description: target[i].description ?? detailed.description,
          openingHours: target[i].openingHours ?? detailed.openingHours,
          phoneContact: target[i].phoneContact ?? detailed.phoneContact,
          averageRating: target[i].averageRating ?? detailed.averageRating,
          totalReviews: target[i].totalReviews ?? detailed.totalReviews,
          minPrice: target[i].minPrice ?? detailed.minPrice,
          maxPrice: target[i].maxPrice ?? detailed.maxPrice,
          images: detailed.images,
          amenities: target[i].amenities ?? detailed.amenities,
          fields: target[i].fields ?? detailed.fields,
          isActive: target[i].isActive ?? detailed.isActive,
          ownerId: target[i].ownerId ?? detailed.ownerId,
          ownerName: target[i].ownerName ?? detailed.ownerName,
        );
        target[i] = updated;
      }
    }
    venues.refresh();
  }

  void search(String query) {
    searchQuery.value = query;
    loadVenues();
  }
}
