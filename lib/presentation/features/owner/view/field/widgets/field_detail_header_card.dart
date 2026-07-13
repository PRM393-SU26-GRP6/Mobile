import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/field_model.dart';
import 'package:exe101/presentation/features/owner/view/field/widgets/field_detail_card_shell.dart';
import 'package:exe101/presentation/features/owner/view/shared/owner_helpers.dart';
import 'package:flutter/material.dart';

class FieldDetailHeaderCard extends StatelessWidget {
  final FieldModel field;

  const FieldDetailHeaderCard({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    return FieldDetailCardShell(
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.buttonGradientStart,
                  AppColors.buttonGradientEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.sports_soccer,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.fieldName ?? 'San khong ten',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.groups_outlined,
                      label: fieldTypeLabel(field.fieldType),
                    ),
                    _InfoChip(
                      icon: field.isActive == true
                          ? Icons.check_circle_outline
                          : Icons.pause_circle_outline,
                      label:
                          field.isActive == true ? 'Dang hoat dong' : 'Tam tat',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FieldDetailStatusCard extends StatelessWidget {
  final FieldModel field;
  final bool isToggling;
  final VoidCallback onToggle;

  const FieldDetailStatusCard({
    super.key,
    required this.field,
    required this.isToggling,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = field.isActive ?? false;
    final color = isActive ? Colors.green.shade700 : Colors.red.shade700;

    return FieldDetailCardShell(
      child: Row(
        children: [
          Icon(isActive ? Icons.check_circle : Icons.cancel, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trang thai hoat dong',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                Text(
                  isActive ? 'Dang hoat dong' : 'Tam tat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          if (isToggling)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Switch(
              value: isActive,
              onChanged: (_) => onToggle(),
              activeThumbColor: AppColors.primary,
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
