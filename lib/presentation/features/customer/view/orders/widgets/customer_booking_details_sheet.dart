import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/customer_booking_details_widgets.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/customer_review_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showCustomerBookingDetailsSheet(String bookingId) {
  return Get.bottomSheet<void>(
    _CustomerBookingDetailsSheet(bookingId: bookingId),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _CustomerBookingDetailsSheet extends StatelessWidget {
  final String bookingId;

  const _CustomerBookingDetailsSheet({required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: FutureBuilder<BookingDto?>(
        future: Get.find<ApiServiceImpl>().getBookingById(bookingId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 260,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return ErrorContent(onClose: Get.back);
          }

          return _BookingDetailsContent(booking: snapshot.data!);
        },
      ),
    );
  }
}

class _BookingDetailsContent extends StatelessWidget {
  final BookingDto booking;

  const _BookingDetailsContent({required this.booking});

  @override
  Widget build(BuildContext context) {
    final firstItem =
        booking.items?.isNotEmpty == true ? booking.items!.first : null;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.inputBorder,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Chi tiết đơn đặt sân',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              StatusPill(label: booking.statusLabel),
            ],
          ),
          const SizedBox(height: 18),
          DetailRow('Mã đơn', _shortId(booking.id)),
          DetailRow('Sân', firstItem?.venueName ?? 'Sân bóng'),
          DetailRow('Mặt sân', firstItem?.fieldName ?? 'Sân'),
          DetailRow('Thời gian', _timeRange(booking)),
          DetailRow('Số khung', '${booking.items?.length ?? 0}'),
          DetailRow('Tổng tiền', _money(booking.totalPrice)),
          DetailRow('Tiền cọc', _money(booking.depositAmount)),
          DetailRow('Đã thanh toán cọc', _money(booking.paidDepositAmount)),
          if ((booking.note ?? '').trim().isNotEmpty)
            DetailRow('Ghi chú', booking.note!.trim()),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.inputBorder),
          const SizedBox(height: 14),
          const Text(
            'Thanh toán',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ..._paymentRows,
          const SizedBox(height: 18),
          CustomerReviewSection(booking: booking),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: Get.back,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Đóng'),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> get _paymentRows {
    final payments = booking.payments ?? const <PaymentDto>[];
    if (payments.isEmpty) {
      return const [
        Text(
          'Chưa có giao dịch thanh toán.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ];
    }

    return payments
        .map(
          (payment) => PaymentRow(
            title:
                '${payment.paymentType ?? 'Payment'} - ${payment.paymentMethod ?? ''}',
            subtitle: payment.paymentStatus ?? '',
            amount: _money(payment.amount ?? 0),
          ),
        )
        .toList();
  }
}

String _shortId(String value) {
  if (value.length <= 8) return value;
  return value.substring(0, 8);
}

String _timeRange(BookingDto booking) {
  final items = booking.items;
  if (items == null || items.isEmpty) return '';
  final first = items.first.startTime;
  final last = items.last.endTime;
  final date = '${first.day}/${first.month}/${first.year}';
  final start = _hhmm(first);
  final end = _hhmm(last);
  return '$date - $start den $end';
}

String _hhmm(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _money(double value) => '${value.toStringAsFixed(0)} VND';
