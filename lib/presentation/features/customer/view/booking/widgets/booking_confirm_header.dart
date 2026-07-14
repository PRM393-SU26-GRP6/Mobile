import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BookingConfirmHeader extends StatelessWidget {
  const BookingConfirmHeader({
    required this.canClose,
    required this.onClose,
    super.key,
  });

  final bool canClose;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.calendar_month,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Text(
            'Xác nhận đặt sân',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (canClose)
          IconButton(
            tooltip: 'Đóng',
            onPressed: onClose,
            icon: const Icon(Icons.close),
          ),
      ],
    );
  }
}
