import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BookingReviewActions extends StatelessWidget {
  final VoidCallback onEditTap;
  final VoidCallback onDeleteTap;

  const BookingReviewActions({
    super.key,
    required this.onEditTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        _ReviewActionButton(
          icon: Icons.rate_review_outlined,
          label: 'Sửa feedback',
          color: AppColors.accent,
          onTap: onEditTap,
        ),
        _ReviewActionButton(
          icon: Icons.delete_outline,
          label: 'Xóa feedback',
          color: Colors.red.shade600,
          onTap: onDeleteTap,
        ),
      ],
    );
  }
}

class _ReviewActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ReviewActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
