import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class VenueLocationPickerPage extends StatefulWidget {
  const VenueLocationPickerPage({super.key});

  @override
  State<VenueLocationPickerPage> createState() =>
      _VenueLocationPickerPageState();
}

class _VenueLocationPickerPageState extends State<VenueLocationPickerPage> {
  static const _fallback = LatLng(10.7769, 106.7009);
  late LatLng _selected;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    final latitude =
        args is Map ? (args['latitude'] as num?)?.toDouble() : null;
    final longitude =
        args is Map ? (args['longitude'] as num?)?.toDouble() : null;
    _selected = latitude == null ||
            longitude == null ||
            (latitude == 0 && longitude == 0)
        ? _fallback
        : LatLng(latitude, longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Chọn vị trí venue'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _selected, zoom: 15),
        markers: {
          Marker(markerId: const MarkerId('venue'), position: _selected),
        },
        onTap: (position) => setState(() => _selected = position),
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: PointerInterceptor(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: () => Get.back(result: {
              'latitude': _selected.latitude,
              'longitude': _selected.longitude,
            }),
            icon: const Icon(Icons.check),
            label: const Text('Dùng vị trí này'),
          ),
        ),
      ),
    );
  }
}
