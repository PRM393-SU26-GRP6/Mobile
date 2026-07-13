import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/data/remote/schedule/owner_resource_api_service.dart';
import 'package:exe101/data/remote/owner/owner_stats_api_service.dart';
import 'package:exe101/domain/repositories/owner_management_repository.dart';
import 'package:exe101/presentation/features/owner/controller/add_field_controller.dart';
import 'package:exe101/presentation/features/owner/controller/booking_management_controller.dart';
import 'package:exe101/presentation/features/owner/controller/field_detail_controller.dart';
import 'package:exe101/presentation/features/owner/controller/owner_home_controller.dart';
import 'package:exe101/presentation/features/owner/controller/revenue_controller.dart';
import 'package:exe101/presentation/features/owner/controller/slot_actions_controller.dart';
import 'package:exe101/presentation/features/owner/controller/slot_filter_controller.dart';
import 'package:exe101/presentation/features/owner/controller/slot_management_controller.dart';
import 'package:exe101/presentation/features/owner/controller/slot_selection_controller.dart';
import 'package:exe101/presentation/features/owner/controller/venue_creation_controller.dart';
import 'package:exe101/presentation/features/owner/controller/venue_images_controller.dart';
import 'package:exe101/presentation/features/owner/controller/venue_edit_controller.dart';
import 'package:exe101/presentation/features/owner/controller/discount_management_controller.dart';
import 'package:get/get.dart';

class OwnerBinding extends Bindings {
  @override
  void dependencies() {
    final apiService = Get.find<ApiServiceImpl>();
    final statsService = Get.find<OwnerStatsApiService>();
    final resourceService = Get.find<OwnerResourceApiService>();

    if (!Get.isRegistered<OwnerManagementRepository>()) {
      Get.put<OwnerManagementRepository>(
        OwnerManagementRepository(
          statsService: statsService,
          resourceService: resourceService,
        ),
      );
    }
    final ownerRepository = Get.find<OwnerManagementRepository>();

    Get.lazyPut<OwnerHomeController>(
      () => OwnerHomeController(apiService: apiService),
    );
    Get.lazyPut<VenueCreationController>(
      () => VenueCreationController(apiService: apiService),
    );
    Get.lazyPut<AddFieldController>(
      () => AddFieldController(apiService: apiService),
    );
    Get.lazyPut<BookingManagementController>(
      () => BookingManagementController(
        apiService: apiService,
        ownerResourceService: resourceService,
      ),
    );
    Get.lazyPut<FieldDetailController>(
      () => FieldDetailController(apiService: apiService),
    );
    Get.lazyPut<SlotManagementController>(
      () => SlotManagementController(apiService: apiService),
      fenix: true,
    );
    Get.lazyPut<SlotActionsController>(
      () => SlotActionsController(
        apiService: apiService,
        ownerRepository: ownerRepository,
      ),
      fenix: true,
    );
    Get.lazyPut<SlotSelectionController>(
      () => SlotSelectionController(),
      fenix: true,
    );
    Get.lazyPut<SlotFilterController>(SlotFilterController.new, fenix: true);
    Get.lazyPut<RevenueController>(
      () => RevenueController(ownerRepository: ownerRepository),
    );
    Get.lazyPut<VenueImagesController>(
      () => VenueImagesController(ownerRepository: ownerRepository),
    );
    Get.lazyPut<VenueEditController>(
      () => VenueEditController(apiService: apiService),
      fenix: true,
    );
    Get.lazyPut<DiscountManagementController>(
      () => DiscountManagementController(apiService: apiService),
    );
  }
}
