import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SlotSelectionToolbar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onSelectAll;
  final VoidCallback onDelete;
  final VoidCallback onClear;

  const SlotSelectionToolbar({
    super.key,
    required this.selectedCount,
    required this.onSelectAll,
    required this.onDelete,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Đã chọn $selectedCount khung giờ',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: onSelectAll,
            child: const Text('Tất cả'),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            color: Colors.red,
            tooltip: 'Xóa khung giờ đã chọn',
          ),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.close),
            color: AppColors.textSecondary,
            tooltip: 'Bỏ chọn',
          ),
        ],
      ),
    );
  }
}
