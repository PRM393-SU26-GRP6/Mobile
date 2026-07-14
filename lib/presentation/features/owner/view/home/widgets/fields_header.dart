import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FieldsHeader extends StatelessWidget {
  const FieldsHeader({super.key, required this.onCreateField});

  final VoidCallback onCreateField;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Danh sách mặt sân',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          FilledButton.icon(
            onPressed: onCreateField,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Thêm'),
            style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
          ),
        ],
      ),
    );
  }
}
