import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';
import 'package:exe101/presentation/features/customer/view/booking/widgets/booking_info_row.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingConfirmSummary extends StatelessWidget {
  const BookingConfirmSummary({
    required this.bookingController,
    required this.venueName,
    required this.fieldName,
    required this.slotCount,
    super.key,
  });

  final BookingController bookingController;
  final String venueName;
  final String fieldName;
  final int slotCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          BookingInfoRow(
            icon: Icons.sports_soccer,
            label: 'Sân',
            value: fieldName,
            valueIcon: Icons.stadium,
          ),
          const _Divider(),
          BookingInfoRow(
            icon: Icons.location_on,
            label: 'Địa điểm',
            value: venueName,
            valueIcon: Icons.map,
          ),
          const _Divider(),
          BookingInfoRow(
            icon: Icons.access_time,
            label: 'Số khung giờ',
            value: '$slotCount khung',
            valueIcon: Icons.timer,
          ),
          const _Divider(),
          Obx(
            () => Column(
              children: [
                if (bookingController.isDiscountValid.value) ...[
                  BookingInfoRow(
                    icon: Icons.money_off,
                    label: 'Giảm giá',
                    value:
                        '-${bookingController.discountAmount.value.toStringAsFixed(0)}đ',
                    valueIcon: Icons.local_offer,
                    valueColor: Colors.green,
                  ),
                  const _Divider(),
                ],
                BookingInfoRow(
                  icon: Icons.payments,
                  label: 'Tổng tiền',
                  value:
                      '${bookingController.finalPrice.value.toStringAsFixed(0)}đ',
                  valueIcon: Icons.receipt_long,
                  isBold: true,
                  valueColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(height: 1, color: AppColors.inputBorder),
    );
  }
}
