import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/owner/view/shared/owner_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showBookingDetailsSheet(BookingDto booking) {
  return Get.bottomSheet(
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
            _DetailRow(label: 'Mã đơn', value: booking.id.substring(0, 8)),
            _DetailRow(label: 'Sân', value: _fieldName(booking)),
            _DetailRow(
              label: 'Thời gian',
              value:
                  '${formatDateVN(booking.startTime)} - ${formatTimeHM(booking.startTime)} đến ${formatTimeHM(booking.endTime)}',
            ),
            _DetailRow(
              label: 'Tổng tiền',
              value: '${booking.totalPrice.toStringAsFixed(0)} VNĐ',
            ),
            if (booking.depositAmount > 0)
              _DetailRow(
                label: booking.depositRequirementLabel,
                value:
                    '${(booking.hasSuccessfulDepositPayment ? booking.paidDepositAmount : booking.depositAmount).toStringAsFixed(0)} VNĐ',
              ),
            if (booking.discountAmount > 0)
              _DetailRow(
                label: 'Giảm giá',
                value: '${booking.discountAmount.toStringAsFixed(0)} VNĐ',
              ),
            _DetailRow(label: 'Trạng thái', value: booking.statusLabel),
            _DetailRow(
                label: 'Ngày tạo', value: formatDateVN(booking.createdAt)),
            if (booking.note != null && booking.note!.isNotEmpty)
              _DetailRow(label: 'Ghi chú', value: booking.note!),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
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
}

String _fieldName(BookingDto booking) {
  if (booking.items != null && booking.items!.isNotEmpty) {
    return booking.items!.first.fieldName ?? 'Sân';
  }
  return 'Sân';
}
