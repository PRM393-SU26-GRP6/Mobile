import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Banner thông tin ngắn ở đầu các tab slot.
class SlotInfoCard extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final IconData icon;

  const SlotInfoCard({
    super.key,
    required this.message,
    this.backgroundColor = const Color(0xFFF0F8FF),
    this.borderColor = const Color(0xFFBBDEFB),
    this.iconColor = const Color(0xFF1976D2),
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
