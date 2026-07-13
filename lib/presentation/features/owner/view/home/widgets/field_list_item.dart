import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/field_model.dart';
import 'package:flutter/material.dart';

class FieldListItem extends StatelessWidget {
  final FieldModel field;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const FieldListItem({
    super.key,
    required this.field,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final fieldTypeLabel =
        FieldModel.fieldTypeLabels[field.fieldType] ?? field.fieldType ?? 'San';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.inputBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _FieldIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: _FieldSummary(
                name: field.fieldName ?? 'San khong ten',
                typeLabel: fieldTypeLabel,
                description: field.description,
              ),
            ),
            _FieldActions(isActive: field.isActive == true, onEdit: onEdit),
          ],
        ),
      ),
    );
  }
}

class _FieldIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.sports_soccer,
        color: AppColors.primary,
        size: 26,
      ),
    );
  }
}

class _FieldSummary extends StatelessWidget {
  final String name;
  final String typeLabel;
  final String? description;

  const _FieldSummary({
    required this.name,
    required this.typeLabel,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Chip(
          label: Text(typeLabel),
          labelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
          backgroundColor: AppColors.secondary,
          side: BorderSide.none,
          visualDensity: VisualDensity.compact,
        ),
        if (description != null && description!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            description!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class _FieldActions extends StatelessWidget {
  final bool isActive;
  final VoidCallback onEdit;

  const _FieldActions({required this.isActive, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isActive ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            isActive ? 'Hoat dong' : 'Tat',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onEdit,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.edit_outlined,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
