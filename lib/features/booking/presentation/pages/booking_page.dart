import 'package:flutter/material.dart';

import '../../../../core/settings/app_settings.dart';
import '../../data/auth_models.dart';
import '../../data/booking_mock_data.dart';
import '../../domain/booking_models.dart';
import '../screens/account_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/chat_room_screen.dart';
import '../screens/conversations_screen.dart';
import '../screens/login_screen.dart';
import '../screens/map_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/success_screen.dart';
import '../screens/venue_detail_screen.dart';
import '../screens/venue_list_screen.dart';
import '../widgets/navigation/pitch_bottom_nav.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({required this.settings, super.key});

  final AppSettings settings;

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  BookingScreen _screen = BookingScreen.splash;
  Venue _selectedVenue = bookingVenues.first;
  FieldInfo _selectedField = bookingVenues.first.fields.first;
  final List<CartItem> _cart = [];
  PaymentInfo? _paymentInfo;
  String? _accessToken;
  String? _refreshToken;
  AuthUser? _authUser;
  List<CartItem> _successCart = [];
  int _successTotal = 0;
  String _successDiscountCode = '';
  String _chatName = 'Chủ sân Thống Nhất';

  void _go(BookingScreen screen) {
    setState(() => _screen = screen);
  }

  void _saveAuth(AuthResponse response) {
    _accessToken = response.accessToken;
    _refreshToken = response.refreshToken;
    _authUser = response.user;
  }

  void _logout() {
    setState(() {
      _accessToken = null;
      _refreshToken = null;
      _authUser = null;
      _screen = BookingScreen.login;
    });
  }

  void _openVenue(Venue venue) {
    setState(() {
      _selectedVenue = venue;
      _selectedField = venue.fields.isEmpty
          ? FieldInfo(
              id: '${venue.id}-default-field',
              name: 'Sân mặc định',
              type: venue.types.isEmpty ? '5' : venue.types.first,
              price: venue.priceFrom,
            )
          : venue.fields.first;
      _screen = BookingScreen.venueDetail;
    });
  }

  void _toggleCartSlot(SlotInfo slot, String date) {
    if (slot.status != SlotStatus.available) return;
    final cartId = '${_selectedField.id}-$date-${slot.id}';
    setState(() {
      final index = _cart.indexWhere((item) => item.id == cartId);
      if (index >= 0) {
        _cart.removeAt(index);
      } else {
        _cart.add(
          CartItem(
            id: cartId,
            venueName: _selectedVenue.name,
            fieldName: _selectedField.name,
            date: date,
            time: slot.time,
            price: _selectedField.price,
          ),
        );
      }
    });
  }

  void _checkout(PaymentInfo info) {
    setState(() {
      _paymentInfo = info;
      _screen = BookingScreen.payment;
    });
  }

  void _confirmPayment() {
    final info = _paymentInfo;
    if (info == null) return;
    setState(() {
      _successCart = List.of(info.cart);
      _successTotal = info.total;
      _successDiscountCode = info.discountCode;
      _cart.clear();
      _screen = BookingScreen.success;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showNav = {
      BookingScreen.venueList,
      BookingScreen.cart,
      BookingScreen.notifications,
      BookingScreen.conversations,
      BookingScreen.map,
      BookingScreen.account,
    }.contains(_screen);

    return Scaffold(
      backgroundColor: const Color(0xFFF2FAF4),
      body: SafeArea(
        top: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _buildScreen(),
        ),
      ),
      bottomNavigationBar: showNav
          ? PitchBottomNav(
              screen: _screen,
              cartCount: _cart.length,
              onChange: _go,
            )
          : null,
    );
  }

  Widget _buildScreen() {
    switch (_screen) {
      case BookingScreen.splash:
        return SplashScreen(onDone: () => _go(BookingScreen.login));
      case BookingScreen.login:
        return LoginScreen(
          onAuthenticated: _saveAuth,
          onLogin: () => _go(BookingScreen.venueList),
        );
      case BookingScreen.venueList:
        return VenueListScreen(
          cartCount: _cart.length,
          onOpenCart: () => _go(BookingScreen.cart),
          onOpenNotifications: () => _go(BookingScreen.notifications),
          onSelectVenue: _openVenue,
        );
      case BookingScreen.venueDetail:
        return VenueDetailScreen(
          venue: _selectedVenue,
          selectedField: _selectedField,
          cart: _cart,
          onBack: () => _go(BookingScreen.venueList),
          onFieldChanged: (field) => setState(() => _selectedField = field),
          onToggleSlot: _toggleCartSlot,
          onGoCart: () => _go(BookingScreen.cart),
        );
      case BookingScreen.cart:
        return CartScreen(
          cart: _cart,
          onBack: () => _go(BookingScreen.venueList),
          onRemove: (item) => setState(() => _cart.remove(item)),
          onCheckout: _checkout,
        );
      case BookingScreen.payment:
        return PaymentScreen(
          info: _paymentInfo!,
          onBack: () => _go(BookingScreen.cart),
          onConfirm: _confirmPayment,
        );
      case BookingScreen.success:
        return SuccessScreen(
          cart: _successCart,
          total: _successTotal,
          discountCode: _successDiscountCode,
          onViewDetail: () => _go(BookingScreen.payment),
          onGoHome: () => _go(BookingScreen.venueList),
        );
      case BookingScreen.notifications:
        return NotificationsScreen(onBack: () => _go(BookingScreen.venueList));
      case BookingScreen.conversations:
        return ConversationsScreen(
          onSelect: (name) {
            setState(() {
              _chatName = name;
              _screen = BookingScreen.chatRoom;
            });
          },
        );
      case BookingScreen.chatRoom:
        return ChatRoomScreen(
          ownerName: _chatName,
          onBack: () => _go(BookingScreen.conversations),
        );
      case BookingScreen.map:
        return MapScreen(onSelectVenue: _openVenue);
      case BookingScreen.account:
        return AccountScreen(
          settings: widget.settings,
          user: _authUser,
          accessToken: _refreshToken == null ? null : _accessToken,
          onLogout: _logout,
        );
    }
  }
}
