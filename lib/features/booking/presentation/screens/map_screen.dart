import 'package:flutter/material.dart';

import '../../data/booking_mock_data.dart';
import '../../data/venue_api_client.dart';
import '../../domain/booking_models.dart';
import '../widgets/booking_ui.dart';
import '../widgets/map/map_background.dart';
import '../widgets/map/map_marker.dart';
import '../widgets/map/map_search_bar.dart';
import '../widgets/map/nearby_list.dart';
import '../widgets/map/selected_venue_sheet.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({required this.onSelectVenue, super.key});

  final ValueChanged<Venue> onSelectVenue;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final VenueApiClient _api = VenueApiClient();
  bool _showList = false;
  bool _liked = false;
  bool _loading = true;
  List<Venue> _venues = bookingVenues;
  Venue? _selectedVenue;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNearby();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  Future<void> _loadNearby() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final venues = await _api.getNearbyVenues(
        latitude: 10.7769,
        longitude: 106.7009,
        radius: 5,
      );
      if (!mounted) return;
      setState(() {
        _venues = venues.isEmpty ? bookingVenues : venues;
        _selectedVenue = _venues.first;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _venues = bookingVenues;
        _selectedVenue = bookingVenues.first;
        _loading = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedVenue ?? _venues.first;

    return Stack(
      key: const ValueKey('map'),
      children: [
        const Positioned.fill(child: MapBackground()),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 12,
          left: 16,
          right: 16,
          child: MapSearchBar(
            onToggleList: () => setState(() => _showList = !_showList),
          ),
        ),
        ..._buildMarkers(context),
        Positioned(
          right: 16,
          bottom: 220,
          child: FloatingActionButton.small(
            heroTag: 'location',
            onPressed: _loadNearby,
            backgroundColor: Colors.white,
            foregroundColor: bookingPrimary,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.navigation_outlined),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: _showList
              ? NearbyList(venues: _venues, onSelectVenue: widget.onSelectVenue)
              : SelectedVenueSheet(
                  venue: selected,
                  liked: _liked,
                  apiFallback: _error != null,
                  onToggleLike: () => setState(() => _liked = !_liked),
                  onSelectVenue: () => widget.onSelectVenue(selected),
                ),
        ),
      ],
    );
  }

  List<Widget> _buildMarkers(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final positions = [
      Offset(size.width * 0.22, 150),
      Offset(size.width * 0.62, 240),
      Offset(size.width * 0.38, 345),
      Offset(size.width * 0.76, 120),
    ];

    return List.generate(_venues.length.clamp(0, positions.length), (index) {
      final venue = _venues[index];
      final active = venue.id == _selectedVenue?.id;
      return MapMarker(
        top: positions[index].dy,
        left: positions[index].dx,
        label: venue.distance == null
            ? '${index + 1}'
            : venue.distance!.toStringAsFixed(1),
        active: active,
        onTap: () => setState(() => _selectedVenue = venue),
      );
    });
  }
}
