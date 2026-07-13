import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:flutter/material.dart';

Future<void> showVenuePickerSheet(
  BuildContext context, {
  required List<VenueModel> venues,
  required VenueModel? selectedVenue,
  required ValueChanged<VenueModel> onSelected,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'Chọn venue quản lý',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: venues.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final venue = venues[index];
                final selected = venue.id == selectedVenue?.id;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondary,
                    child: Icon(
                      selected ? Icons.check : Icons.stadium_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    venue.venueName ?? 'Venue chưa đặt tên',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: venue.address?.isNotEmpty == true
                      ? Text(
                          venue.address!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  selected: selected,
                  onTap: () {
                    onSelected(venue);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
