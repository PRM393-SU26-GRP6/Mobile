import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';
import 'package:exe101/presentation/features/customer/controller/venue_controller.dart';
import 'package:exe101/presentation/features/customer/controller/venue_detail_controller.dart';
import 'package:get/get.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    final apiService = Get.find<ApiServiceImpl>();
    Get.lazyPut<VenueController>(() => VenueController(apiService: apiService));
    Get.lazyPut<VenueDetailController>(() => VenueDetailController(apiService: apiService));
    Get.lazyPut<BookingController>(() => BookingController(apiService: apiService));
  }
}
