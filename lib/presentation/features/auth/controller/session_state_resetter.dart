import 'package:exe101/data/remote/signalr_service.dart';
import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';
import 'package:exe101/presentation/features/customer/controller/customer_home_controller.dart';
import 'package:exe101/presentation/features/customer/controller/notification_controller.dart';
import 'package:exe101/presentation/features/customer/controller/payment_history_controller.dart';
import 'package:exe101/presentation/features/customer/controller/user_profile_controller.dart';
import 'package:exe101/presentation/features/customer/controller/venue_controller.dart';
import 'package:exe101/presentation/features/customer/controller/venue_detail_controller.dart';
import 'package:exe101/presentation/features/owner/controller/add_field_controller.dart';
import 'package:exe101/presentation/features/owner/controller/booking_management_controller.dart';
import 'package:exe101/presentation/features/owner/controller/discount_management_controller.dart';
import 'package:exe101/presentation/features/owner/controller/field_detail_controller.dart';
import 'package:exe101/presentation/features/owner/controller/owner_home_controller.dart';
import 'package:exe101/presentation/features/owner/controller/revenue_controller.dart';
import 'package:exe101/presentation/features/owner/controller/slot_actions_controller.dart';
import 'package:exe101/presentation/features/owner/controller/slot_management_controller.dart';
import 'package:exe101/presentation/features/owner/controller/slot_selection_controller.dart';
import 'package:exe101/presentation/features/owner/controller/venue_creation_controller.dart';
import 'package:exe101/presentation/features/owner/controller/venue_edit_controller.dart';
import 'package:exe101/presentation/features/owner/controller/venue_images_controller.dart';
import 'package:get/get.dart';

class SessionStateResetter {
  const SessionStateResetter._();

  static Future<void> clearUserBoundState() async {
    if (Get.isRegistered<SignalRService>()) {
      await Get.find<SignalRService>().stopConnections();
    }

    await _delete<BookingController>();
    await _delete<CustomerHomeController>();
    await _delete<NotificationController>();
    await _delete<PaymentHistoryController>();
    await _delete<UserProfileController>();
    await _delete<VenueController>();
    await _delete<VenueDetailController>();

    await _delete<AddFieldController>();
    await _delete<BookingManagementController>();
    await _delete<DiscountManagementController>();
    await _delete<FieldDetailController>();
    await _delete<OwnerHomeController>();
    await _delete<RevenueController>();
    await _delete<SlotActionsController>();
    await _delete<SlotManagementController>();
    await _delete<SlotSelectionController>();
    await _delete<VenueCreationController>();
    await _delete<VenueEditController>();
    await _delete<VenueImagesController>();
  }

  static Future<void> _delete<T>() async {
    if (Get.isRegistered<T>()) {
      await Get.delete<T>(force: true);
    }
  }
}
