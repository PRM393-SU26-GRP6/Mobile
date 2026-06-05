import 'package:flutter/material.dart';

import '../../data/booking_mock_data.dart';
import '../../data/venue_api_client.dart';
import '../../domain/booking_models.dart';
import '../widgets/booking_ui.dart';
import '../widgets/venue_detail/date_option.dart';
import '../widgets/venue_detail/venue_detail_content.dart';

class VenueDetailScreen extends StatefulWidget {
  const VenueDetailScreen({
    required this.venue,
    required this.selectedField,
    required this.cart,
    required this.onBack,
    required this.onFieldChanged,
    required this.onToggleSlot,
    required this.onGoCart,
    super.key,
  });

  final Venue venue;
  final FieldInfo selectedField;
  final List<CartItem> cart;
  final VoidCallback onBack;
  final ValueChanged<FieldInfo> onFieldChanged;
  final void Function(SlotInfo slot, String date) onToggleSlot;
  final VoidCallback onGoCart;

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  final VenueApiClient _api = VenueApiClient();
  late Venue _venue;
  late String _date;
  List<SlotInfo> _slots = bookingSlots;
  bool _loadingDetail = true;
  bool _loadingSlots = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _venue = widget.venue;
    _date = _formatDate(DateTime.now());
    _loadVenueDetail();
  }

  @override
  void didUpdateWidget(covariant VenueDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.venue.id != widget.venue.id) {
      _venue = widget.venue;
      _slots = bookingSlots;
      _loadVenueDetail();
    }
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  FieldInfo get _activeField {
    return _venue.fields.firstWhere(
      (field) => field.id == widget.selectedField.id,
      orElse: () => _venue.fields.first,
    );
  }

  Future<void> _loadVenueDetail() async {
    setState(() {
      _loadingDetail = true;
      _error = null;
    });

    try {
      final detail = await _api.getVenueDetailData(widget.venue.id);
      if (!mounted) return;
      final fields = detail.venue.fields.isEmpty
          ? widget.venue.fields
          : detail.venue.fields;
      final selected =
          fields.any((field) => field.id == widget.selectedField.id)
          ? widget.selectedField
          : fields.first;

      setState(() {
        _venue = detail.venue.copyWith(fields: fields);
        _loadingDetail = false;
      });

      if (selected.id != widget.selectedField.id) {
        widget.onFieldChanged(selected);
      }
      await _loadSlots(selected);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _venue = widget.venue;
        _slots = bookingSlots;
        _loadingDetail = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _loadSlots(FieldInfo field) async {
    if (field.id.contains('default-field')) {
      setState(() => _slots = bookingSlots);
      return;
    }

    setState(() => _loadingSlots = true);
    try {
      final slots = await _api.getFieldSlots(fieldId: field.id, date: _date);
      if (!mounted) return;
      setState(() {
        _slots = slots.isEmpty ? bookingSlots : slots;
        _loadingSlots = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _slots = bookingSlots;
        _loadingSlots = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BookingShell(
      key: ValueKey('venue-${widget.venue.id}'),
      child: Column(
        children: [
          BookingTopBar(
            title: 'Chi tiết sân',
            onBack: widget.onBack,
            trailing: BookingCartIcon(
              count: widget.cart.length,
              onTap: widget.onGoCart,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadVenueDetail,
              child: VenueDetailContent(
                venue: _venue,
                originalVenue: widget.venue,
                activeField: _activeField,
                slots: _slots,
                cart: widget.cart,
                date: _date,
                dateOptions: _dateOptions(),
                loadingDetail: _loadingDetail,
                loadingSlots: _loadingSlots,
                showFallbackNotice: _error != null,
                onSelectField: _selectField,
                onDateChanged: _setDate,
                onToggleSlot: widget.onToggleSlot,
              ),
            ),
          ),
          BookingBottomAction(
            label: widget.cart.isEmpty
                ? 'Chọn slot để đặt sân'
                : 'Xem giỏ (${widget.cart.length})',
            icon: Icons.shopping_cart_outlined,
            enabled: widget.cart.isNotEmpty,
            onPressed: widget.onGoCart,
          ),
        ],
      ),
    );
  }

  void _selectField(FieldInfo field) {
    widget.onFieldChanged(field);
    _loadSlots(field);
  }

  void _setDate(String date) {
    setState(() => _date = date);
    _loadSlots(_activeField);
  }

  List<DateOption> _dateOptions() {
    final now = DateTime.now();
    return [
      DateOption(label: 'Hôm nay', date: _formatDate(now)),
      DateOption(
        label: 'Ngày mai',
        date: _formatDate(now.add(const Duration(days: 1))),
      ),
      DateOption(
        label: 'Ngày kia',
        date: _formatDate(now.add(const Duration(days: 2))),
      ),
    ];
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
