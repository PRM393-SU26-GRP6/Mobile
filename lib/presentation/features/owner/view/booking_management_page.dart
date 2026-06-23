import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/auth/controller/auth_controller.dart';
import 'package:exe101/presentation/features/owner/controller/booking_management_controller.dart';
import 'package:exe101/presentation/features/owner/view/widgets/booking_filter_chips.dart';
import 'package:exe101/presentation/features/owner/view/widgets/booking_list_item.dart';
import 'package:exe101/presentation/features/owner/view/widgets/booking_stats_card.dart';
import 'package:exe101/presentation/features/owner/view/widgets/empty_bookings_widget.dart';
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
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
            onPressed: () => _showLogoutDialog(context),
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
                      .map((e) => {'value': e['value'] as String, 'label': e['label'] as String})
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
                    message: controller.selectedFilter.value == 'Pending'
                        ? 'Không có đơn chờ duyệt'
                        : controller.selectedFilter.value == 'all'
                            ? 'Chưa có đơn đặt sân nào'
                            : 'Không có đơn ${controller.filterOptions.firstWhere((e) => e['value'] == controller.selectedFilter.value)['label']}',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return BookingListItem(
                      booking: booking,
                      onTap: () => _showBookingDetails(booking),
                      onAccept: () => _showAcceptDialog(booking),
                      onReject: () => _showRejectDialog(booking),
                      onComplete: () => _showCompleteDialog(booking),
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

  void _showBookingDetails(BookingDto booking) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Chi Tiết Đặt Sân',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Mã đơn', booking.id.substring(0, 8)),
              _buildDetailRow('Sân', _getFieldName(booking)),
              _buildDetailRow('Thời gian', '${_formatDate(booking.startTime)} - ${_formatTime(booking.startTime)} đến ${_formatTime(booking.endTime)}'),
              _buildDetailRow('Tổng tiền', '${booking.totalPrice.toStringAsFixed(0)} VNĐ'),
              if (booking.depositAmount > 0)
                _buildDetailRow('Đã đặt cọc', '${booking.depositAmount.toStringAsFixed(0)} VNĐ'),
              if (booking.discountAmount > 0)
                _buildDetailRow('Giảm giá', '${booking.discountAmount.toStringAsFixed(0)} VNĐ'),
              _buildDetailRow('Trạng thái', booking.statusLabel),
              _buildDetailRow('Ngày tạo', _formatDate(booking.createdAt)),
              if (booking.note != null && booking.note!.isNotEmpty)
                _buildDetailRow('Ghi chú', booking.note!),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Đóng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFieldName(BookingDto booking) {
    if (booking.items != null && booking.items!.isNotEmpty) {
      return booking.items!.first.fieldName ?? 'Sân';
    }
    return 'Sân';
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showAcceptDialog(BookingDto booking) {
    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Bạn có muốn chấp nhận đặt sân "${_getFieldName(booking)}" không?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              Get.find<BookingManagementController>().acceptBooking(booking.id);
            },
            child: const Text('Chấp nhận'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BookingDto booking) {
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Từ chối đặt sân'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Vui lòng nhập lý do từ chối:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'VD: Sân không trống vào khung giờ này',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              Get.find<BookingManagementController>().rejectBooking(
                booking.id,
                reasonController.text.isEmpty ? 'Không có lý do' : reasonController.text,
              );
            },
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(BookingDto booking) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hoàn thành đặt sân'),
        content: Text('Xác nhận hoàn thành đặt sân "${_getFieldName(booking)}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              Get.find<BookingManagementController>().completeBooking(booking.id);
            },
            child: const Text('Hoàn thành'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              Get.find<AuthController>().logout();
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
