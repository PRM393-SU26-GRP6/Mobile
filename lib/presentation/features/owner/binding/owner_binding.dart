import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/presentation/features/owner/controller/add_field_controller.dart';
import 'package:exe101/presentation/features/owner/controller/booking_management_controller.dart';
import 'package:exe101/presentation/features/owner/controller/create_field_controller.dart';
import 'package:exe101/presentation/features/owner/controller/field_detail_controller.dart';
import 'package:exe101/presentation/features/owner/controller/owner_home_controller.dart';
import 'package:exe101/presentation/features/owner/controller/slot_management_controller.dart';
import 'package:exe101/presentation/features/owner/controller/venue_creation_controller.dart';
import 'package:get/get.dart';

class OwnerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OwnerHomeController>(
      () => OwnerHomeController(apiService: Get.find<ApiServiceImpl>()),
    );
    Get.lazyPut<VenueCreationController>(
      () => VenueCreationController(apiService: Get.find<ApiServiceImpl>()),
    );
    Get.lazyPut<AddFieldController>(
      () => AddFieldController(apiService: Get.find<ApiServiceImpl>()),
    );
    Get.lazyPut<CreateFieldController>(
      () => CreateFieldController(apiService: Get.find<ApiServiceImpl>()),
    );
    Get.lazyPut<BookingManagementController>(
      () => BookingManagementController(apiService: Get.find<ApiServiceImpl>()),
    );
    Get.lazyPut<FieldDetailController>(
      () => FieldDetailController(apiService: Get.find<ApiServiceImpl>()),
    );
    Get.lazyPut<SlotManagementController>(
      () => SlotManagementController(apiService: Get.find<ApiServiceImpl>()),
    );
  }
}
