import 'package:exe101/data/remote/venue/venue_api_service.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:get/get.dart';

class VenueMapController extends GetxController {
  VenueMapController({required this.venueApiService});

  static const defaultLatitude = 10.7769;
  static const defaultLongitude = 106.7009;

  final VenueApiService venueApiService;
  final venues = <VenueModel>[].obs;
  final selectedVenue = Rxn<VenueModel>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  List<VenueModel> get mappedVenues => venues.where(_hasValidLocation).toList();

  @override
  void onInit() {
    super.onInit();
    loadVenues();
  }

  Future<void> loadVenues() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      venues.assignAll(await venueApiService.getVenues(pageSize: 100));
      if (mappedVenues.isNotEmpty) {
        selectedVenue.value ??= mappedVenues.first;
      }
    } catch (_) {
      errorMessage.value = 'Không thể tải dữ liệu bản đồ';
    } finally {
      isLoading.value = false;
    }
  }

  void selectVenue(VenueModel venue) => selectedVenue.value = venue;

  void clearSelection() => selectedVenue.value = null;

  bool _hasValidLocation(VenueModel venue) {
    final latitude = venue.latitude;
    final longitude = venue.longitude;
    if (latitude == null || longitude == null) return false;
    if (latitude == 0 && longitude == 0) return false;
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }
}
