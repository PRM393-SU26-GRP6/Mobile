import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/field_model.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:get/get.dart';

class OwnerHomeController extends GetxController {
  final ApiServiceImpl apiService;

  OwnerHomeController({required this.apiService});

  final venues = <VenueModel>[].obs;
  final selectedVenue = Rxn<VenueModel>();
  final fields = <FieldModel>[].obs;
  final isLoadingVenues = false.obs;
  final isLoadingFields = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadVenues();
  }

  Future<void> loadVenues() async {
    isLoadingVenues.value = true;
    try {
      final result = await apiService.getMyVenues();
      venues.assignAll(result);
      if (result.isEmpty) {
        selectedVenue.value = null;
        fields.clear();
        return;
      }

      final selectedVenueId = selectedVenue.value?.id;
      final matchingVenue =
          result.where((venue) => venue.id == selectedVenueId);
      if (matchingVenue.isNotEmpty) {
        selectVenue(matchingVenue.first);
      } else {
        selectVenue(result.first);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách sân');
    } finally {
      isLoadingVenues.value = false;
    }
  }

  Future<void> loadFields(String venueId) async {
    isLoadingFields.value = true;
    try {
      final result = await apiService.getOwnerFieldsByVenue(venueId);
      fields.assignAll(result);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách sân con');
    } finally {
      isLoadingFields.value = false;
    }
  }

  void selectVenue(VenueModel venue) {
    selectedVenue.value = venue;
    loadFields(venue.id);
  }

  Future<void> refreshAll() async {
    await loadVenues();
    if (selectedVenue.value != null) {
      await loadFields(selectedVenue.value!.id);
    }
  }
}
