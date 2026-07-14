import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/customer_booking_details_widgets.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/customer_review_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerBookingDetailsContent extends StatelessWidget {
  const CustomerBookingDetailsContent({super.key, required this.booking});

  final BookingDto booking;

  @override
  Widget build(BuildContext context) {
    final item = booking.items?.firstOrNull;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: _SheetHandle()),
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
          DetailRow('Cụm sân', item?.venueName ?? 'Sân bóng'),
          DetailRow('Mặt sân', item?.fieldName ?? 'Sân'),
          DetailRow('Thời gian', _timeRange(booking)),
          DetailRow('Số khung giờ', '${booking.items?.length ?? 0}'),
          DetailRow('Tổng tiền', _money(booking.totalPrice)),
          DetailRow('Tiền cọc', _money(booking.depositAmount)),
          DetailRow('Đã thanh toán cọc', _money(booking.paidDepositAmount)),
          if ((booking.note ?? '').trim().isNotEmpty)
            DetailRow('Ghi chú', booking.note!.trim()),
          const Divider(height: 32, color: AppColors.inputBorder),
          const Text(
            'Thanh toán',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ..._paymentRows(booking),
          const SizedBox(height: 18),
          CustomerReviewSection(booking: booking),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: Get.back,
              child: const Text('Đóng'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) => Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.inputBorder,
          borderRadius: BorderRadius.circular(999),
        ),
      );
}

List<Widget> _paymentRows(BookingDto booking) {
  final payments = booking.payments ?? const <PaymentDto>[];
  if (payments.isEmpty) {
    return const [Text('Chưa có giao dịch thanh toán.')];
  }
  return payments
      .map(
        (payment) => PaymentRow(
          title:
              '${payment.paymentType ?? 'Thanh toán'} - ${payment.paymentMethod ?? ''}',
          subtitle: payment.paymentStatus ?? '',
          amount: _money(payment.amount ?? 0),
        ),
      )
      .toList();
}

String _shortId(String value) =>
    value.length <= 8 ? value : value.substring(0, 8);

String _timeRange(BookingDto booking) {
  final items = booking.items;
  if (items == null || items.isEmpty) return '';
  final first = items.first.startTime;
  final last = items.last.endTime;
  return '${first.day}/${first.month}/${first.year} - '
      '${_hhmm(first)} đến ${_hhmm(last)}';
}

String _hhmm(DateTime value) => '${value.hour.toString().padLeft(2, '0')}:'
    '${value.minute.toString().padLeft(2, '0')}';

String _money(double value) => '${value.toStringAsFixed(0)} VND';
