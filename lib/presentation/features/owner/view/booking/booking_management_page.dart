import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/booking_management_controller.dart';
import 'package:exe101/presentation/features/owner/view/booking/widgets/booking_decision_dialog.dart';
import 'package:exe101/presentation/features/owner/view/booking/widgets/booking_details_sheet.dart';
import 'package:exe101/presentation/features/owner/view/booking/widgets/booking_filter_chips.dart';
import 'package:exe101/presentation/features/owner/view/booking/widgets/booking_list_item.dart';
import 'package:exe101/presentation/features/owner/view/booking/widgets/booking_stats_card.dart';
import 'package:exe101/presentation/features/owner/view/booking/widgets/empty_bookings_widget.dart';
import 'package:exe101/presentation/features/owner/view/shared/owner_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingManagementPage extends StatelessWidget {
  const BookingManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingManagementController>();

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Duyệt Đặt Sân',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Get.offAllNamed(AppPages.ownerHome),
            tooltip: 'Về trang chủ',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => showOwnerLogoutDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshAll(),
        color: AppColors.primary,
        child: Column(
          children: [
            Obx(() => BookingStatsCard(
                  pendingCount: controller.pendingCount,
                  todayCount: controller.todayBookings.length,
                  totalCount: controller.bookings.length,
                )),
            Obx(() => BookingFilterChips(
                  selectedFilter: controller.selectedFilter.value,
                  onFilterChanged: controller.setFilter,
                  options: controller.filterOptions
                      .map((e) => {
                            'value': e['value'] as String,
                            'label': e['label'] as String
                          })
                      .toList(),
                )),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                final bookings = controller.filteredBookings;
                if (bookings.isEmpty) {
                  return EmptyBookingsWidget(
                    message: _emptyMessageFor(controller.selectedFilter.value),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return BookingListItem(
                      booking: booking,
                      onTap: () => showBookingDetailsSheet(booking),
                      onAccept: () => showAcceptBookingDialog(booking),
                      onReject: () => showRejectBookingDialog(booking),
                      onComplete: () => showCompleteBookingDialog(booking),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        if (controller.pendingCount > 0) {
          return FloatingActionButton.extended(
            onPressed: () => controller.setFilter('Pending'),
            backgroundColor: Colors.orange,
            icon: const Icon(Icons.pending_actions, color: Colors.white),
            label: Text(
              '${controller.pendingCount} chờ duyệt',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  String _emptyMessageFor(String filter) {
    if (filter == 'Pending') return 'Không có đơn chờ duyệt';
    if (filter == 'all') return 'Chưa có đơn đặt sân nào';
    final matched =
        Get.find<BookingManagementController>().filterOptions.firstWhere(
              (e) => e['value'] == filter,
              orElse: () => {'label': 'này'},
            );
    return 'Không có đơn ${matched['label']}';
  }
}
