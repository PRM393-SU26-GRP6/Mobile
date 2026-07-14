import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/field_model.dart';
import 'package:flutter/material.dart';

class FieldTypeSection extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const FieldTypeSection({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Loại Sân', Icons.category_outlined),
        const SizedBox(height: 12),
        Row(
          children: FieldModel.fieldTypes.map((type) {
            final isSelected = selectedType == type;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: type != FieldModel.fieldTypes.last ? 10 : 0,
                ),
                child: _buildTypeCard(type, isSelected),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeCard(String type, bool isSelected) {
    final label = FieldModel.fieldTypeLabels[type] ?? type;
    final players = type == 'FiveASide'
        ? '5 người'
        : type == 'SevenASide'
            ? '7 người'
            : '11 người';

    return GestureDetector(
      onTap: () => onTypeChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inputBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sports_soccer,
              size: 32,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              players,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.8)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
