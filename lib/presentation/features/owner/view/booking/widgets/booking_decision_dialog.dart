import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/owner/controller/booking_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showAcceptBookingDialog(BookingDto booking) async {
  return Get.dialog(
    AlertDialog(
      title: const Text('Xác nhận'),
      content: Text(
        'Bạn có muốn chấp nhận đặt sân "${_fieldName(booking)}" không?',
      ),
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

Future<void> showRejectBookingDialog(BookingDto booking) async {
  final reasonController = TextEditingController();
  return Get.dialog(
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
              reasonController.text.isEmpty
                  ? 'Không có lý do'
                  : reasonController.text,
            );
          },
          child: const Text('Từ chối'),
        ),
      ],
    ),
  );
}

Future<void> showCompleteBookingDialog(BookingDto booking) async {
  return Get.dialog(
    AlertDialog(
      title: const Text('Hoàn thành đặt sân'),
      content: Text(
        'Xác nhận hoàn thành đặt sân "${_fieldName(booking)}"?',
      ),
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

String _fieldName(BookingDto booking) {
  if (booking.items != null && booking.items!.isNotEmpty) {
    return booking.items!.first.fieldName ?? 'Sân';
  }
  return 'Sân';
}
