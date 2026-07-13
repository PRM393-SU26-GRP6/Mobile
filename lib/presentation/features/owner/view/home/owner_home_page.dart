import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:exe101/domain/repositories/user_repository.dart';
import 'package:exe101/presentation/features/customer/controller/notification_controller.dart';
import 'package:exe101/presentation/features/customer/view/messages/messages_page.dart';
import 'package:exe101/presentation/features/customer/view/notifications/notifications_page.dart';
import 'package:exe101/presentation/features/owner/controller/booking_management_controller.dart';
import 'package:exe101/presentation/features/owner/controller/owner_home_controller.dart';
import 'package:exe101/presentation/features/owner/controller/revenue_controller.dart';
import 'package:exe101/presentation/features/owner/view/booking/booking_management_page.dart';
import 'package:exe101/presentation/features/owner/view/home/widgets/owner_fields_tab.dart';
import 'package:exe101/presentation/features/owner/view/home/widgets/owner_nav_bar.dart';
import 'package:exe101/presentation/features/owner/view/revenue/revenue_page.dart';
import 'package:exe101/presentation/features/owner/view/shared/owner_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ownerController = Get.find<OwnerHomeController>();
    final bookingController = Get.find<BookingManagementController>();
    final notificationController = _getNotificationController();

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: _selectedIndex <= 2 ? _buildAppBar() : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          OwnerFieldsTab(
            controller: ownerController,
            onCreateVenue: _openCreateVenue,
            onCreateField: _openCreateField,
            onOpenField: _openFieldDetail,
            onEditField: _showEditFieldDialog,
            onEditVenue: _openVenueEdit,
          ),
          const BookingManagementPage(embedded: true),
          const RevenuePage(embedded: true),
          const MessagesPage(),
          const NotificationsPage(),
        ],
      ),
      bottomNavigationBar: Obx(
        () => OwnerNavBar(
          selectedIndex: _selectedIndex,
          pendingCount: bookingController.pendingCount,
          notificationCount: notificationController.unreadCount.value,
          onFieldsTap: () => _selectTab(0),
          onBookingsTap: () => _selectTab(1),
          onRevenueTap: () => _selectTab(2),
          onMessagesTap: () => _selectTab(3),
          onNotificationsTap: () => _selectTab(4),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        _titleForTab(),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        if (_selectedIndex == 0)
          IconButton(
            icon: const Icon(Icons.discount),
            onPressed: () => Get.toNamed(AppPages.ownerDiscountManagement),
          ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshCurrentTab,
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => showOwnerLogoutDialog(context),
        ),
      ],
    );
  }

  String _titleForTab() {
    switch (_selectedIndex) {
      case 1:
        return 'Duyệt Đặt Sân';
      case 2:
        return 'Doanh Thu';
      default:
        return 'Quản Lý Sân';
    }
  }

  void _selectTab(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  void _refreshCurrentTab() {
    if (_selectedIndex == 0) {
      Get.find<OwnerHomeController>().refreshAll();
    } else if (_selectedIndex == 1) {
      Get.find<BookingManagementController>().refreshAll();
    } else if (_selectedIndex == 2) {
      Get.find<RevenueController>().refresh();
    }
  }

  NotificationController _getNotificationController() {
    if (Get.isRegistered<NotificationController>()) {
      return Get.find<NotificationController>();
    }
    if (!Get.isRegistered<UserRepository>()) {
      Get.put<UserRepository>(
        UserRepository(apiService: Get.find<ApiServiceImpl>()),
      );
    }
    return Get.put(
      NotificationController(userRepository: Get.find<UserRepository>()),
    );
  }

  void _openCreateField(String venueId, String venueName) {
    Get.toNamed(
      AppPages.addField,
      arguments: {'venueId': venueId, 'venueName': venueName},
    )?.then((_) => Get.find<OwnerHomeController>().refreshAll());
  }

  void _openCreateVenue() {
    Get.toNamed(AppPages.venueCreation)
        ?.then((_) => Get.find<OwnerHomeController>().refreshAll());
  }

  void _openVenueEdit(VenueModel venue) {
    Get.toNamed(AppPages.venueEdit, arguments: venue)
        ?.then((_) => Get.find<OwnerHomeController>().refreshAll());
  }

  void _openFieldDetail(String fieldId) {
    Get.toNamed(AppPages.fieldDetail, arguments: {'fieldId': fieldId});
  }

  void _showEditFieldDialog(String fieldName) {
    Get.snackbar('Sửa', 'Chỉnh sửa: $fieldName');
  }
}
