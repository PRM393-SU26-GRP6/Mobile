import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/data/remote/venue/venue_api_service.dart';
import 'package:exe101/domain/repositories/review_repository.dart';
import 'package:exe101/domain/repositories/slot_repository.dart';
import 'package:exe101/domain/repositories/user_repository.dart';
import 'package:exe101/domain/repositories/booking_repository.dart';
import 'package:exe101/domain/repositories/chat_repository.dart';
import 'package:exe101/domain/repositories/payment_repository.dart';
import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';
import 'package:exe101/presentation/features/customer/controller/customer_home_controller.dart';
import 'package:exe101/presentation/features/customer/controller/venue_controller.dart';
import 'package:exe101/presentation/features/customer/controller/venue_detail_controller.dart';
import 'package:exe101/presentation/features/customer/controller/venue_map_controller.dart';
import 'package:exe101/presentation/features/customer/controller/payment_history_controller.dart';
import 'package:exe101/presentation/features/customer/controller/notification_controller.dart';
import 'package:exe101/presentation/features/customer/controller/booking_details_controller.dart';
import 'package:exe101/presentation/features/customer/controller/chat_actions_controller.dart';
import 'package:exe101/presentation/features/customer/controller/payment_actions_controller.dart';
import 'package:exe101/presentation/features/auth/controller/auth_controller.dart';
import 'package:get/get.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    final apiService = Get.find<ApiServiceImpl>();

    if (!Get.isRegistered<VenueApiService>()) {
      Get.lazyPut<VenueApiService>(() => apiService.venueService, fenix: true);
    }

    if (!Get.isRegistered<UserRepository>()) {
      Get.lazyPut<UserRepository>(
        () => UserRepository(apiService: apiService),
        fenix: true,
      );
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(
        () => AuthController(userRepository: Get.find()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<BookingRepository>()) {
      Get.lazyPut<BookingRepository>(
        () => BookingRepository(bookingApiService: apiService.bookingService),
        fenix: true,
      );
    }
    if (!Get.isRegistered<ChatRepository>()) {
      Get.lazyPut<ChatRepository>(
        () => ChatRepository(
          authApiService: apiService.authService,
          chatApiService: apiService.chatService,
          venueApiService: apiService.venueService,
        ),
        fenix: true,
      );
    }
    if (!Get.isRegistered<PaymentRepository>()) {
      Get.lazyPut<PaymentRepository>(
        () => PaymentRepository(paymentApiService: apiService.paymentService),
        fenix: true,
      );
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
    Get.lazyPut<NotificationController>(
      () => NotificationController(userRepository: Get.find()),
      fenix: true,
    );
    Get.lazyPut<BookingDetailsController>(
      () => BookingDetailsController(bookingRepository: Get.find()),
      fenix: true,
    );
    Get.lazyPut<ChatActionsController>(
      () => ChatActionsController(
        chatRepository: Get.find(),
        signalRService: Get.find(),
      ),
      fenix: true,
    );
    Get.lazyPut<PaymentActionsController>(
      () => PaymentActionsController(paymentRepository: Get.find()),
      fenix: true,
    );
  }
}
