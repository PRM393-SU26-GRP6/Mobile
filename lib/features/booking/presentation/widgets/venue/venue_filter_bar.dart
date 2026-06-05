import 'package:flutter/material.dart';

import 'package:prm_web/features/booking/data/venue_api_models.dart';
import '../booking_ui.dart';
import 'venue_api_notice.dart';

class VenueFilterBar extends StatelessWidget {
  const VenueFilterBar({
    required this.selectedType,
    required this.selectedAmenityId,
    required this.amenities,
    required this.showApiFallbackNotice,
    required this.onQueryChanged,
    required this.onTypeChanged,
    required this.onAmenityChanged,
    required this.onRetry,
    super.key,
  });

  final String selectedType;
  final String? selectedAmenityId;
  final List<AmenityFilter> amenities;
  final bool showApiFallbackNotice;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onAmenityChanged;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      child: Column(
        children: [
          TextField(
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Tìm tên sân hoặc khu vực',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: bookingLine),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...['Tat ca', '5', '7', '11'].map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(type == 'Tat ca' ? 'Tất cả' : 'Sân $type'),
                      selected: selectedType == type,
                      onSelected: (_) => onTypeChanged(type),
                    ),
                  );
                }),
                ...amenities.map((amenity) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(amenity.name),
                      selected: selectedAmenityId == amenity.id,
                      onSelected: (_) => onAmenityChanged(amenity.id),
                    ),
                  );
                }),
              ],
            ),
          ),
          if (showApiFallbackNotice) ...[
            const SizedBox(height: 10),
            VenueApiNotice(onRetry: onRetry),
          ],
        ],
      ),
    );
  }
}
