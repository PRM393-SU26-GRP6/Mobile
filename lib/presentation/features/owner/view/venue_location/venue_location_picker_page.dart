import 'package:exe101/core/config/map_config.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/venue_location_picker_controller.dart';
import 'package:exe101/presentation/features/owner/view/venue_location/widgets/venue_location_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class VenueLocationPickerPage extends StatefulWidget {
  const VenueLocationPickerPage({super.key});

  @override
  State<VenueLocationPickerPage> createState() =>
      _VenueLocationPickerPageState();
}

class _VenueLocationPickerPageState extends State<VenueLocationPickerPage> {
  late final VenueLocationPickerController _controller;
  final _mapController = MapController();
  late final Worker _locationWorker;
  bool _mapReady = false;
  LatLng? _pendingLocation;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<VenueLocationPickerController>();
    _locationWorker = ever<LatLng>(
      _controller.selectedLocation,
      _moveToLocation,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _controller.initialize(ModalRoute.of(context)?.settings.arguments);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _controller.searchInitialAddress(),
    );
  }

  void _moveToLocation(LatLng location) {
    if (!_mapReady) {
      _pendingLocation = location;
      return;
    }
    _mapController.move(location, 16);
  }

  void _onMapReady() {
    _mapReady = true;
    final pendingLocation = _pendingLocation;
    if (pendingLocation != null) {
      _pendingLocation = null;
      _mapController.move(pendingLocation, 16);
    }
  }

  void _search() {
    FocusScope.of(context).unfocus();
    _controller.searchAddress();
  }

  @override
  void dispose() {
    _locationWorker.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Chọn vị trí venue'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _controller.selectedLocation.value,
              initialZoom: 15,
              onMapReady: _onMapReady,
              onTap: (_, position) => _controller.selectManually(position),
            ),
            children: [
              TileLayer(
                urlTemplate: MapConfig.tileUrl,
                userAgentPackageName: MapConfig.userAgentPackageName,
              ),
              Obx(
                () => MarkerLayer(
                  markers: [
                    Marker(
                      point: _controller.selectedLocation.value,
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 44,
                      ),
                    ),
                  ],
                ),
              ),
              const SimpleAttributionWidget(
                source: Text('OpenStreetMap contributors'),
              ),
            ],
          ),
          SafeArea(
            minimum: const EdgeInsets.all(12),
            child: Obx(
              () => VenueLocationSearch(
                controller: _controller.searchController,
                isSearching: _controller.isSearching.value,
                message: _controller.searchMessage.value,
                isSuccess: _controller.searchSucceeded.value,
                onSearch: _search,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: () {
            final selected = _controller.selectedLocation.value;
            Navigator.of(context).pop({
              'latitude': selected.latitude,
              'longitude': selected.longitude,
            });
          },
          icon: const Icon(Icons.check),
          label: const Text('Dùng vị trí này'),
        ),
      ),
    );
  }
}
