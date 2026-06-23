import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:get/get.dart';

class VenueController extends GetxController {
  final ApiService apiService;

  final venues = <VenueModel>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;
  final searchQuery = ''.obs;
  final page = 1.obs;
  final int pageSize = 5;
  final hasMore = true.obs;
  final isLoadingMore = false.obs;

  VenueController({required this.apiService});

  @override
  void onInit() {
    super.onInit();
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
        final fetched = await (apiService as ApiServiceImpl).getVenues(
          q: searchQuery.value.isNotEmpty ? searchQuery.value : null,
          page: page.value,
          pageSize: pageSize,
        );

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

  void search(String query) {
    searchQuery.value = query;
    loadVenues();
  }
}
