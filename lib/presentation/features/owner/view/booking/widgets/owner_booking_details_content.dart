import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/owner/view/booking/widgets/owner_booking_review_section.dart';
import 'package:exe101/presentation/features/owner/view/shared/owner_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OwnerBookingDetailsContent extends StatelessWidget {
  const OwnerBookingDetailsContent({super.key, required this.booking});

  final BookingDto booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: _Handle()),
            const SizedBox(height: 20),
            const Text(
              'Chi tiết đặt sân',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            OwnerBookingDetailRow('Mã đơn', _shortId(booking.id)),
            OwnerBookingDetailRow(
              'Sân',
              booking.items?.firstOrNull?.fieldName ?? 'Sân',
            ),
            OwnerBookingDetailRow(
              'Thời gian',
              '${formatDateVN(booking.startTime)} - '
                  '${formatTimeHM(booking.startTime)} đến '
                  '${formatTimeHM(booking.endTime)}',
            ),
            OwnerBookingDetailRow(
              'Tổng tiền',
              '${booking.totalPrice.toStringAsFixed(0)} VNĐ',
            ),
            if (booking.depositAmount > 0)
              OwnerBookingDetailRow(
                booking.depositRequirementLabel,
                '${(booking.hasSuccessfulDepositPayment ? booking.paidDepositAmount : booking.depositAmount).toStringAsFixed(0)} VNĐ',
              ),
            if (booking.discountAmount > 0)
              OwnerBookingDetailRow(
                'Giảm giá',
                '${booking.discountAmount.toStringAsFixed(0)} VNĐ',
              ),
            OwnerBookingDetailRow('Trạng thái', booking.statusLabel),
            OwnerBookingDetailRow('Ngày tạo', formatDateVN(booking.createdAt)),
            if ((booking.customerName ?? '').isNotEmpty)
              OwnerBookingDetailRow('Khách hàng', booking.customerName!),
            if ((booking.note ?? '').isNotEmpty)
              OwnerBookingDetailRow('Ghi chú', booking.note!),
            const SizedBox(height: 8),
            const Text(
              'Đánh giá của khách hàng',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            OwnerBookingReviewSection(booking: booking),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: Get.back,
                child: const Text('Đóng'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OwnerBookingDetailRow extends StatelessWidget {
  const OwnerBookingDetailRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      );
}

String _shortId(String id) => id.length > 8 ? id.substring(0, 8) : id;
