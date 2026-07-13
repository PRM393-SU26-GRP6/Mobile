import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VenueLocationSelection {
  const VenueLocationSelection({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

Future<VenueLocationSelection?> pickVenueLocation(
  BuildContext context, {
  double? latitude,
  double? longitude,
  String? address,
}) async {
  final routeResult = await Get.toNamed(
    AppPages.venueLocationPicker,
    arguments: {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    },
  );
  final result = routeResult is Map ? routeResult : null;
  final selectedLatitude = (result?['latitude'] as num?)?.toDouble();
  final selectedLongitude = (result?['longitude'] as num?)?.toDouble();
  if (selectedLatitude == null || selectedLongitude == null) return null;

  return VenueLocationSelection(
    latitude: selectedLatitude,
    longitude: selectedLongitude,
  );
}

class VenueLocationField extends StatelessWidget {
  const VenueLocationField({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.onTap,
  });

  final double? latitude;
  final double? longitude;
  final VoidCallback onTap;

  bool get hasLocation =>
      latitude != null &&
      longitude != null &&
      !(latitude == 0 && longitude == 0);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.inputBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.map_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vị trí trên bản đồ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasLocation
                          ? '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}'
                          : 'Chạm để chọn tọa độ venue',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
