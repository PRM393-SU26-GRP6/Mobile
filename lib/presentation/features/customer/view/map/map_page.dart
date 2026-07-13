import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/venue_map_controller.dart';
import 'package:exe101/presentation/features/customer/view/map/widgets/map_venue_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VenueMapController>();

    return Stack(
      children: [
        Obx(
          () => GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: VenueMapController.initialPosition,
              zoom: 11,
            ),
            markers: controller.markers,
            onMapCreated: controller.onMapCreated,
            onTap: (_) => controller.clearSelection(),
            compassEnabled: true,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: PointerInterceptor(
              child: Container(
                height: 52,
                margin: const EdgeInsets.all(12),
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsets.only(left: 16, right: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.map_outlined, color: AppColors.primary),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Bản đồ sân bóng',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Tải lại',
                      onPressed: controller.loadVenues,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (controller.errorMessage.isNotEmpty) {
            return _MapNotice(message: controller.errorMessage.value);
          }
          if (controller.mappedVenues.isEmpty) {
            return const _MapNotice(
              message: 'Chưa có sân nào được cập nhật tọa độ trên bản đồ.',
            );
          }
          return const SizedBox.shrink();
        }),
        Obx(() {
          final venue = controller.selectedVenue.value;
          if (venue == null) return const SizedBox.shrink();
          return Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: PointerInterceptor(child: MapVenuePreview(venue: venue)),
            ),
          );
        }),
      ],
    );
  }
}

class _MapNotice extends StatelessWidget {
  const _MapNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PointerInterceptor(
        child: Container(
          margin: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.location_off_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }
}
