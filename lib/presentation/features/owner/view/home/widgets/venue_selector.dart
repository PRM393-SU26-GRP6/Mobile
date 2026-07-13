import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:exe101/presentation/features/owner/view/home/widgets/venue_picker_sheet.dart';
import 'package:flutter/material.dart';

class VenueSelector extends StatelessWidget {
  const VenueSelector({
    super.key,
    required this.venues,
    required this.selectedVenue,
    required this.onVenueSelected,
    required this.onAddVenue,
  });

  final List<VenueModel> venues;
  final VenueModel? selectedVenue;
  final ValueChanged<VenueModel> onVenueSelected;
  final VoidCallback onAddVenue;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: venues.isEmpty
                ? const _EmptyVenueLabel()
                : _SelectedVenueButton(
                    venue: selectedVenue ?? venues.first,
                    onTap: () => showVenuePickerSheet(
                      context,
                      venues: venues,
                      selectedVenue: selectedVenue,
                      onSelected: onVenueSelected,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            tooltip: 'Thêm venue',
            onPressed: onAddVenue,
            style: IconButton.styleFrom(backgroundColor: AppColors.primary),
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SelectedVenueButton extends StatelessWidget {
  const _SelectedVenueButton({required this.venue, required this.onTap});

  final VenueModel venue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.venueName ?? 'Venue chưa đặt tên',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (venue.address?.isNotEmpty == true)
                    Text(
                      venue.address!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.expand_more, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _EmptyVenueLabel extends StatelessWidget {
  const _EmptyVenueLabel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.textSecondary),
          SizedBox(width: 10),
          Expanded(child: Text('Bạn chưa có venue nào')),
        ],
      ),
    );
  }
}
