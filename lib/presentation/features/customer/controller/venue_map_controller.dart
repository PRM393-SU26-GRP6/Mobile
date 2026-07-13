import 'package:exe101/data/remote/venue/venue_api_service.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VenueMapController extends GetxController {
  VenueMapController({required this.venueApiService});

  static const initialPosition = LatLng(10.7769, 106.7009);

  final VenueApiService venueApiService;
  final venues = <VenueModel>[].obs;
  final selectedVenue = Rxn<VenueModel>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  GoogleMapController? _mapController;

  List<VenueModel> get mappedVenues => venues.where(_hasValidLocation).toList();

  Set<Marker> get markers => mappedVenues
      .map(
        (venue) => Marker(
          markerId: MarkerId(venue.id),
          position: LatLng(venue.latitude!, venue.longitude!),
          infoWindow: InfoWindow(
            title: venue.venueName ?? 'Sân bóng',
            snippet: venue.address,
          ),
          onTap: () => selectVenue(venue, moveCamera: false),
        ),
      )
      .toSet();

  @override
  void onInit() {
    super.onInit();
    loadVenues();
  }

  @override
  void onClose() {
    _mapController?.dispose();
    super.onClose();
  }

  Future<void> loadVenues() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      venues.assignAll(await venueApiService.getVenues(pageSize: 100));
      if (mappedVenues.isNotEmpty) {
        selectedVenue.value ??= mappedVenues.first;
        await _moveTo(selectedVenue.value!);
      }
    } catch (_) {
      errorMessage.value = 'Không thể tải dữ liệu bản đồ';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    final selected = selectedVenue.value;
    if (selected != null) await _moveTo(selected);
  }

  Future<void> selectVenue(
    VenueModel venue, {
    bool moveCamera = true,
  }) async {
    selectedVenue.value = venue;
    if (moveCamera) await _moveTo(venue);
  }

  void clearSelection() => selectedVenue.value = null;

  Future<void> _moveTo(VenueModel venue) async {
    final controller = _mapController;
    if (controller == null || !_hasValidLocation(venue)) return;
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(venue.latitude!, venue.longitude!),
        14,
      ),
    );
  }

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
