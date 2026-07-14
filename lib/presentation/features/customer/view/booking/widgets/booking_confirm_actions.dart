import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/booking_confirmation_controller.dart';
import 'package:flutter/material.dart';

class BookingConfirmActions extends StatelessWidget {
  const BookingConfirmActions({
    required this.controller,
    required this.onCancel,
    super.key,
  });

  final BookingConfirmationController controller;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: controller.isLoading ? null : onCancel,
            child: const Text('Hủy'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: controller.isLoading ? null : controller.confirm,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: controller.isLoading
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Xác nhận'),
          ),
        ),
      ],
    );
  }
}
