import 'package:flutter/material.dart';

import '../../../domain/booking_models.dart';

class PitchBottomNav extends StatelessWidget {
  const PitchBottomNav({
    required this.screen,
    required this.cartCount,
    required this.onChange,
    super.key,
  });

  final BookingScreen screen;
  final int cartCount;
  final ValueChanged<BookingScreen> onChange;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _indexFor(screen),
      onDestinationSelected: (index) {
        onChange(
          [
            BookingScreen.venueList,
            BookingScreen.map,
            BookingScreen.cart,
            BookingScreen.conversations,
            BookingScreen.account,
          ][index],
        );
      },
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Sân',
        ),
        const NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: 'Bản đồ',
        ),
        NavigationDestination(
          icon: Badge(
            label: Text('$cartCount'),
            isLabelVisible: cartCount > 0,
            child: const Icon(Icons.shopping_cart_outlined),
          ),
          selectedIcon: Badge(
            label: Text('$cartCount'),
            isLabelVisible: cartCount > 0,
            child: const Icon(Icons.shopping_cart),
          ),
          label: 'Giỏ',
        ),
        const NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble),
          label: 'Chat',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Tôi',
        ),
      ],
    );
  }

  int _indexFor(BookingScreen screen) {
    return switch (screen) {
      BookingScreen.map => 1,
      BookingScreen.cart => 2,
      BookingScreen.conversations => 3,
      BookingScreen.account => 4,
      _ => 0,
    };
  }
}
