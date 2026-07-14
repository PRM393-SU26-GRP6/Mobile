import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/domain/models/review_model.dart';
import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';
import 'package:exe101/presentation/features/customer/controller/review_form_controller.dart';
import 'package:exe101/presentation/features/customer/view/booking/widgets/review_form_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewFormDialog extends StatefulWidget {
  const ReviewFormDialog({
    required this.booking,
    this.mode = ReviewFormMode.create,
    this.existing,
    super.key,
  });

  final BookingDto booking;
  final ReviewFormMode mode;
  final ReviewModel? existing;

  static Future<bool> showCreate(BookingDto booking) async {
    return await Get.dialog<bool>(
          ReviewFormDialog(booking: booking),
          barrierDismissible: false,
        ) ??
        false;
  }

  static Future<bool> showEdit(
    BookingDto booking,
    ReviewModel existing,
  ) async {
    return await Get.dialog<bool>(
          ReviewFormDialog(
            booking: booking,
            mode: ReviewFormMode.edit,
            existing: existing,
          ),
          barrierDismissible: false,
        ) ??
        false;
  }

  @override
  State<ReviewFormDialog> createState() => _ReviewFormDialogState();
}

class _ReviewFormDialogState extends State<ReviewFormDialog> {
  final formKey = GlobalKey<FormState>();
  late final ReviewFormController controller;

  @override
  void initState() {
    super.initState();
    controller = ReviewFormController(
      bookingController: Get.find<BookingController>(),
      booking: widget.booking,
      mode: widget.mode,
      existing: widget.existing,
    )..addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _submit() async {
    if (formKey.currentState?.validate() != true) return;
    if (!await controller.submit() || !mounted) return;

    Get.back<bool>(result: true);
    Get.snackbar(
      'Thành công',
      controller.successMessage,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
    );
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ReviewFormContent(
            controller: controller,
            formKey: formKey,
            onCancel: () => Get.back<bool>(result: false),
            onSubmit: _submit,
          ),
        ),
      ),
    );
  }
}
