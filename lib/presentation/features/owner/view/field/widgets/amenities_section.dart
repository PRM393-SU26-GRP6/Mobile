import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/field_model.dart';
import 'package:flutter/material.dart';

class AmenitiesSection extends StatelessWidget {
  final List<String> selectedAmenities;
  final ValueChanged<String> onToggle;

  const AmenitiesSection({
    super.key,
    required this.selectedAmenities,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tiện Ích', Icons.star_outline),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Column(
            children:
                FieldModel.availableAmenities.asMap().entries.map((entry) {
              final index = entry.key;
              final amenity = entry.value;
              final isSelected = selectedAmenities.contains(amenity);
              final isLast = index == FieldModel.availableAmenities.length - 1;

              return Column(
                children: [
                  _buildAmenityItem(amenity, isSelected),
                  if (!isLast)
                    const Divider(height: 1, color: AppColors.inputBorder),
                ],
              );
            }).toList(),
          ),
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

  Widget _buildAmenityItem(String amenity, bool isSelected) {
    final amenityIcons = _getAmenityIcon(amenity);

    return InkWell(
      onTap: () => onToggle(amenity),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                amenityIcons,
                size: 18,
                color: isSelected ? AppColors.primary : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                amenity,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAmenityIcon(String amenity) {
    switch (amenity) {
      case 'Đèn chiếu sáng':
        return Icons.lightbulb_outline;
      case 'Nước uống':
        return Icons.water_drop_outlined;
      case 'WiFi':
        return Icons.wifi_outlined;
      case 'Mái che':
        return Icons.roofing_outlined;
      case 'Phòng thay đồ':
        return Icons.checkroom_outlined;
      case 'Căng tin':
        return Icons.restaurant_outlined;
      case 'Bãi đỗ xe':
        return Icons.local_parking_outlined;
      case 'Khu vực giải lao':
        return Icons.weekend_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }
}
