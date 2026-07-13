import 'package:exe101/data/remote/map/geocoding_api_service.dart';
import 'package:exe101/domain/repositories/geocoding_repository.dart';
import 'package:exe101/presentation/features/owner/controller/venue_location_picker_controller.dart';
import 'package:get/get.dart';

class VenueLocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GeocodingApiService>(GeocodingApiService.new);
    Get.lazyPut<GeocodingRepository>(
      () => NominatimGeocodingRepository(apiService: Get.find()),
    );
    Get.lazyPut<VenueLocationPickerController>(
      () => VenueLocationPickerController(geocodingRepository: Get.find()),
    );
  }
}
