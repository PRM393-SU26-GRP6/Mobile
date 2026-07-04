import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Slider chọn giá slot với các nút quick price.
class PriceSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final List<double> quickPrices;
  final ValueChanged<double> onChanged;

  const PriceSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.quickPrices,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.primary.withValues(alpha: 0.2),
                onChanged: onChanged,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${value.toStringAsFixed(0)}đ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final price in quickPrices)
              _QuickPriceChip(
                price: price,
                isSelected: value == price,
                onTap: () => onChanged(price),
              ),
          ],
        ),
      ],
    );
  }
}

class _QuickPriceChip extends StatelessWidget {
  final double price;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickPriceChip({
    required this.price,
    required this.isSelected,
    required this.onTap,
  });

  String _formatPrice(double p) {
    if (p >= 1000) {
      final intPart = (p / 1000).toStringAsFixed(0);
      return '$intPart.000đ';
    }
    return '${p.toStringAsFixed(0)}đ';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inputBorder,
          ),
        ),
        child: Text(
          _formatPrice(price),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
