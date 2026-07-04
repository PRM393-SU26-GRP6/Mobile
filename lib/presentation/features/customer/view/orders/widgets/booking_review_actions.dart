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
        _buildEditButton(),
        _buildDeleteButton(),
      ],
    );
  }

  Widget _buildEditButton() {
    return GestureDetector(
      onTap: onEditTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.accent),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_outlined, size: 14, color: AppColors.accent),
            SizedBox(width: 4),
            Text(
              'Sửa',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: onDeleteTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.red.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, size: 14, color: Colors.red.shade600),
            const SizedBox(width: 4),
            Text(
              'Xóa',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.red.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
