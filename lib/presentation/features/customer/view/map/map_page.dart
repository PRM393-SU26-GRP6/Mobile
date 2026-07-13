import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:exe101/presentation/features/customer/controller/venue_map_controller.dart';
import 'package:exe101/presentation/features/customer/view/map/widgets/map_venue_marker.dart';
import 'package:exe101/presentation/features/customer/view/map/widgets/map_venue_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final _mapController = MapController();

  VenueMapController get _controller => Get.find<VenueMapController>();

  void _selectVenue(VenueModel venue) {
    _controller.selectVenue(venue);
    _mapController.move(_toPoint(venue), 14);
  }

  LatLng _toPoint(VenueModel venue) {
    return LatLng(venue.latitude!, venue.longitude!);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Stack(
      children: [
        Obx(
          () => FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(
                VenueMapController.defaultLatitude,
                VenueMapController.defaultLongitude,
              ),
              initialZoom: 11,
              onTap: (_, __) => controller.clearSelection(),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.exe101',
              ),
              MarkerLayer(
                markers: controller.mappedVenues
                    .map(
                      (venue) => Marker(
                        point: _toPoint(venue),
                        width: 46,
                        height: 46,
                        child: MapVenueMarker(
                          isSelected:
                              controller.selectedVenue.value?.id == venue.id,
                          onTap: () => _selectVenue(venue),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SimpleAttributionWidget(
                source: Text('OpenStreetMap contributors'),
              ),
            ],
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: _MapHeader(onRefresh: controller.loadVenues),
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
              child: MapVenuePreview(venue: venue),
            ),
          );
        }),
      ],
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      margin: const EdgeInsets.all(12),
      constraints: const BoxConstraints(maxWidth: 520),
      padding: const EdgeInsets.only(left: 16, right: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.14), blurRadius: 10),
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
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _MapNotice extends StatelessWidget {
  const _MapNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.12), blurRadius: 10),
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
    );
  }
}
