import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/booking_mock_data.dart';
import '../../data/venue_api_client.dart';
import 'package:prm_web/features/booking/data/venue_api_models.dart';
import '../../domain/booking_models.dart';
import '../widgets/booking_ui.dart';
import '../widgets/venue/venue_filter_bar.dart';
import '../widgets/venue/venue_list_body.dart';
import '../widgets/venue/venue_list_header.dart';

class VenueListScreen extends StatefulWidget {
  const VenueListScreen({
    required this.cartCount,
    required this.onOpenCart,
    required this.onOpenNotifications,
    required this.onSelectVenue,
    super.key,
  });

  final int cartCount;
  final VoidCallback onOpenCart;
  final VoidCallback onOpenNotifications;
  final ValueChanged<Venue> onSelectVenue;

  @override
  State<VenueListScreen> createState() => _VenueListScreenState();
}

class _VenueListScreenState extends State<VenueListScreen> {
  final VenueApiClient _api = VenueApiClient();
  String _query = '';
  String _type = 'Tat ca';
  String? _amenityId;
  Timer? _searchDebounce;
  List<Venue> _venues = bookingVenues;
  List<AmenityFilter> _amenities = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _api.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_loadVenues(), _loadAmenities()]);
  }

  Future<void> _loadAmenities() async {
    try {
      final amenities = await _api.getAmenities();
      if (!mounted) return;
      setState(() => _amenities = amenities);
    } catch (_) {
      if (!mounted) return;
      setState(() => _amenities = const []);
    }
  }

  Future<void> _loadVenues() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final type = _fieldTypeFor(_type);
      final page =
          _query.trim().isNotEmpty && type == null && _amenityId == null
          ? await _api.searchVenues(query: _query.trim())
          : await _api.getVenues(
              query: _query,
              fieldType: type,
              amenityId: _amenityId,
            );
      if (!mounted) return;
      setState(() {
        _venues = page.items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _venues = bookingVenues;
        _loading = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BookingShell(
      key: const ValueKey('venues'),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: VenueListHeader(
              cartCount: widget.cartCount,
              onOpenCart: widget.onOpenCart,
              onOpenNotifications: widget.onOpenNotifications,
            ),
          ),
          SliverToBoxAdapter(
            child: VenueFilterBar(
              selectedType: _type,
              selectedAmenityId: _amenityId,
              amenities: _amenities,
              showApiFallbackNotice: _error != null,
              onQueryChanged: _onQueryChanged,
              onTypeChanged: _setType,
              onAmenityChanged: _setAmenity,
              onRetry: _loadVenues,
            ),
          ),
          VenueListBody(
            loading: _loading,
            venues: _venues,
            onSelectVenue: widget.onSelectVenue,
          ),
        ],
      ),
    );
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), _loadVenues);
  }

  void _setType(String type) {
    setState(() => _type = type);
    _loadVenues();
  }

  void _setAmenity(String amenityId) {
    setState(() {
      _amenityId = _amenityId == amenityId ? null : amenityId;
    });
    _loadVenues();
  }

  String? _fieldTypeFor(String type) {
    return switch (type) {
      '5' => 'FiveASide',
      '7' => 'SevenASide',
      '11' => 'ElevenASide',
      _ => null,
    };
  }
}
