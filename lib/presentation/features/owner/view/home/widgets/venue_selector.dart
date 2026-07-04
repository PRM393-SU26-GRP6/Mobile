import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:flutter/material.dart';

class VenueSelector extends StatelessWidget {
  final List<VenueModel> venues;
  final VenueModel? selectedVenue;
  final ValueChanged<VenueModel> onVenueSelected;
  final VoidCallback onAddVenue;

  const VenueSelector({
    super.key,
    required this.venues,
    required this.selectedVenue,
    required this.onVenueSelected,
    required this.onAddVenue,
  });

  @override
  Widget build(BuildContext context) {
    if (venues.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.inputBorder),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<VenueModel>(
                value: selectedVenue,
                isExpanded: true,
                hint: const Text('Chọn sân'),
                icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                items: venues.map((venue) {
                  return DropdownMenuItem<VenueModel>(
                    value: venue,
                    child: Text(
                      venue.venueName ?? 'Sân không tên',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (venue) {
                  if (venue != null) onVenueSelected(venue);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.inputBorder),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bạn chưa có sân nào',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: onAddVenue,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.buttonGradientStart, AppColors.buttonGradientEnd],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add, size: 16, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'Thêm sân',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
