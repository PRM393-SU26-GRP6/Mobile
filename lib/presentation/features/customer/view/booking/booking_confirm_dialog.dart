import 'package:exe101/presentation/features/customer/controller/booking_confirmation_controller.dart';
import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';
import 'package:exe101/presentation/features/customer/view/booking/widgets/booking_confirm_actions.dart';
import 'package:exe101/presentation/features/customer/view/booking/widgets/booking_confirm_header.dart';
import 'package:exe101/presentation/features/customer/view/booking/widgets/booking_confirm_summary.dart';
import 'package:exe101/presentation/features/customer/view/booking/widgets/booking_discount_field.dart';
import 'package:exe101/presentation/features/customer/view/booking/widgets/booking_confirm_error.dart';
import 'package:exe101/presentation/features/customer/view/booking/widgets/booking_note_field.dart';
import 'package:exe101/presentation/features/customer/view/booking/widgets/booking_success_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingConfirmDialog extends StatefulWidget {
  const BookingConfirmDialog({
    required this.slotIds,
    required this.totalPrice,
    required this.venueName,
    required this.fieldName,
    required this.slotCount,
    super.key,
  });

  final List<String> slotIds;
  final double totalPrice;
  final String venueName;
  final String fieldName;
  final int slotCount;
  static Future<bool> show({
    required List<String> slotIds,
    required double totalPrice,
    required String venueName,
    required String fieldName,
    required int slotCount,
  }) async {
    return await Get.dialog<bool>(
          BookingConfirmDialog(
            slotIds: slotIds,
            totalPrice: totalPrice,
            venueName: venueName,
            fieldName: fieldName,
            slotCount: slotCount,
          ),
          barrierDismissible: false,
        ) ??
        false;
  }

  @override
  State<BookingConfirmDialog> createState() => _BookingConfirmDialogState();
}

class _BookingConfirmDialogState extends State<BookingConfirmDialog> {
  late final BookingConfirmationController controller;
  @override
  void initState() {
    super.initState();
    controller = BookingConfirmationController(
      bookingController: Get.find<BookingController>(),
      slotIds: widget.slotIds,
      totalPrice: widget.totalPrice,
    )..addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_refresh);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: controller.isSuccess
              ? const BookingSuccessView()
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BookingConfirmHeader(
                        canClose: !controller.isLoading,
                        onClose: () => Get.back(result: false),
                      ),
                      const SizedBox(height: 16),
                      BookingConfirmSummary(
                        bookingController: controller.bookingController,
                        venueName: widget.venueName,
                        fieldName: widget.fieldName,
                        slotCount: widget.slotCount,
                      ),
                      const SizedBox(height: 16),
                      BookingDiscountField(controller: controller),
                      const SizedBox(height: 12),
                      BookingNoteField(controller: controller),
                      BookingConfirmError(message: controller.errorMessage),
                      const SizedBox(height: 16),
                      BookingConfirmActions(
                        controller: controller,
                        onCancel: () => Get.back(result: false),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
