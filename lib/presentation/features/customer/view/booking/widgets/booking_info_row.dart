import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BookingInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final IconData? valueIcon;
  final bool isBold;
  final Color? valueColor;

  const BookingInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueIcon,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
        if (valueIcon != null) ...[
          const SizedBox(width: 4),
          Icon(valueIcon, size: 14, color: valueColor ?? AppColors.primary),
        ],
      ],
    );
  }
}
