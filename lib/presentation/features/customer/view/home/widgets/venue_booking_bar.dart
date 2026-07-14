import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/venue_detail_controller.dart';
import 'package:exe101/presentation/features/customer/view/booking/booking_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VenueBookingBar extends StatelessWidget {
  const VenueBookingBar({required this.controller, super.key});

  final VenueDetailController controller;

  Future<void> _confirmBooking() async {
    final slotCount = controller.selectedSlotIds.length;
    final success = await BookingConfirmDialog.show(
      slotIds: controller.selectedSlotIds.toList(),
      totalPrice: controller.totalPrice,
      venueName: controller.venue.value?.venueName ?? '',
      fieldName: controller.selectedField.value?.fieldName ?? '',
      slotCount: slotCount,
    );
    if (!success) return;

    controller.selectedSlotIds.clear();
    final field = controller.selectedField.value;
    if (field != null) await controller.loadSlots(field.id);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final slotCount = controller.selectedSlotIds.length;
      final hasSelection = slotCount > 0;

      return Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.paddingOf(context).bottom + 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hasSelection
                        ? '$slotCount khung giờ đã chọn'
                        : 'Chọn sân và khung giờ',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (hasSelection)
                    Text(
                      '${controller.totalPrice.toStringAsFixed(0)}đ',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                ],
              ),
            ),
            FilledButton(
              onPressed: hasSelection ? _confirmBooking : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
              child: const Text('Đặt sân'),
            ),
          ],
        ),
      );
    });
  }
}
