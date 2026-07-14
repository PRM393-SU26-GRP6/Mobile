import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/domain/models/review_model.dart';
import 'package:exe101/domain/repositories/review_repository.dart';
import 'package:exe101/presentation/features/owner/controller/booking_management_controller.dart';
import 'package:exe101/presentation/features/owner/view/shared/owner_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Hiển thị chi tiết 1 booking dạng bottom sheet.
/// Có tuỳ chọn [refreshFromApi] - nếu true sẽ gọi owner booking API để lấy
/// dữ liệu mới nhất trước khi hiển thị (dùng cho trang detail chuyên biệt).
Future<void> showBookingDetailsSheet(
  BookingDto booking, {
  bool refreshFromApi = false,
}) async {
  BookingDto resolved = booking;
  if (refreshFromApi) {
    final ctrl = Get.find<BookingManagementController>();
    final fresh = await ctrl.fetchBookingDetail(booking.id);
    if (fresh != null) resolved = fresh;
  }
  return Get.bottomSheet(
    _BookingDetailsBody(booking: resolved),
  );
}

class _BookingDetailsBody extends StatelessWidget {
  final BookingDto booking;
  const _BookingDetailsBody({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            _DetailRow(
              label: 'Mã đơn',
              value: booking.id.length >= 8
                  ? booking.id.substring(0, 8)
                  : booking.id,
            ),
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
            if (booking.customerName != null &&
                booking.customerName!.isNotEmpty)
              _DetailRow(label: 'Khách hàng', value: booking.customerName!),
            if (booking.note != null && booking.note!.isNotEmpty)
              _DetailRow(label: 'Ghi chú', value: booking.note!),
            const SizedBox(height: 8),
            const Text(
              'Feedback khách hàng',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            _OwnerBookingReviewSection(booking: booking),
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
    );
  }
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

class _OwnerBookingReviewSection extends StatelessWidget {
  final BookingDto booking;

  const _OwnerBookingReviewSection({required this.booking});

  Future<ReviewModel?> _loadReview() async {
    if (!Get.isRegistered<ReviewRepository>()) return null;
    final dto = await Get.find<ReviewRepository>().getBookingReview(booking.id);
    if (dto == null) return null;
    final firstItem =
        booking.items?.isNotEmpty == true ? booking.items!.first : null;
    return ReviewModel.fromBookingReview(
      dto,
      bookingId: booking.id,
      userId: booking.customerId ?? booking.userId,
      userName: booking.customerName,
      venueId: firstItem?.venueId ?? '',
      venueName: firstItem?.venueName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ReviewModel?>(
      future: _loadReview(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: LinearProgressIndicator(color: AppColors.primary),
          );
        }
        final review = snapshot.data;
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Không thể tải feedback cho đơn này.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          );
        }
        if (review == null) {
          return const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Chưa có feedback cho đơn này.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          );
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.accent,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Đánh giá ${review.rating}/5',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                review.userName ?? 'Khách hàng',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                review.displayComment,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
