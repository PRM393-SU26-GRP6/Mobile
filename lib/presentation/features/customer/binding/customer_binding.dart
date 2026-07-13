import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/data/remote/venue/venue_api_service.dart';
import 'package:exe101/domain/repositories/review_repository.dart';
import 'package:exe101/domain/repositories/slot_repository.dart';
import 'package:exe101/domain/repositories/user_repository.dart';
import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';
import 'package:exe101/presentation/features/customer/controller/customer_home_controller.dart';
import 'package:exe101/presentation/features/customer/controller/venue_controller.dart';
import 'package:exe101/presentation/features/customer/controller/venue_detail_controller.dart';
import 'package:exe101/presentation/features/customer/controller/venue_map_controller.dart';
import 'package:exe101/presentation/features/customer/controller/payment_history_controller.dart';
import 'package:get/get.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    final apiService = Get.find<ApiServiceImpl>();

    if (!Get.isRegistered<VenueApiService>()) {
      Get.lazyPut<VenueApiService>(() => apiService.venueService, fenix: true);
    }

    if (!Get.isRegistered<UserRepository>()) {
      Get.put<UserRepository>(UserRepository(apiService: apiService));
    }

    Get.lazyPut<VenueController>(() => VenueController(apiService: apiService));
    Get.lazyPut<VenueMapController>(
      () => VenueMapController(venueApiService: Get.find<VenueApiService>()),
      fenix: true,
    );
    Get.lazyPut<VenueDetailController>(() => VenueDetailController(
          apiService: apiService,
          slotRepository: Get.find<SlotRepository>(),
          reviewRepository: Get.find<ReviewRepository>(),
        ));
    Get.lazyPut<BookingController>(() => BookingController(
          apiService: apiService,
          reviewRepository: Get.find<ReviewRepository>(),
        ));
    Get.lazyPut<PaymentHistoryController>(() => PaymentHistoryController(
          apiService: apiService,
        ));
    Get.lazyPut<CustomerHomeController>(CustomerHomeController.new,
        fenix: true);
  }
}
