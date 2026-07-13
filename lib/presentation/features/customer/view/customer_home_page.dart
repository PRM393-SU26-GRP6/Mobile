import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/customer_home_controller.dart';
import 'package:exe101/presentation/features/customer/view/cart/cart_page.dart';
import 'package:exe101/presentation/features/customer/view/home/home_page.dart';
import 'package:exe101/presentation/features/customer/view/map/map_page.dart';
import 'package:exe101/presentation/features/customer/view/messages/messages_page.dart';
import 'package:exe101/presentation/features/customer/view/notifications/notifications_page.dart';
import 'package:exe101/presentation/features/customer/view/orders/orders_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  static const _pages = [
    HomePage(),
    MapPage(),
    CartPage(),
    OrdersPage(),
    MessagesPage(),
    NotificationsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomerHomeController>();

    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: _pages,
          )),
      bottomNavigationBar: Obx(
        () => _CustomerBottomNav(
          controller: controller,
          selectedIndex: controller.currentIndex.value,
        ),
      ),
    );
  }
}

class _CustomerBottomNav extends StatelessWidget {
  const _CustomerBottomNav({
    required this.controller,
    required this.selectedIndex,
  });

  final CustomerHomeController controller;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CustomerNavItem(
                  controller: controller,
                  selectedIndex: selectedIndex,
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Trang chu'),
              _CustomerNavItem(
                  controller: controller,
                  selectedIndex: selectedIndex,
                  index: 1,
                  icon: Icons.map_outlined,
                  activeIcon: Icons.map,
                  label: 'Ban do'),
              _CustomerNavItem(
                  controller: controller,
                  selectedIndex: selectedIndex,
                  index: 2,
                  icon: Icons.shopping_cart_outlined,
                  activeIcon: Icons.shopping_cart,
                  label: 'Gio hang'),
              _CustomerNavItem(
                  controller: controller,
                  selectedIndex: selectedIndex,
                  index: 3,
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  label: 'Don hang'),
              _CustomerNavItem(
                  controller: controller,
                  selectedIndex: selectedIndex,
                  index: 4,
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                  label: 'Tin nhan'),
              _CustomerNavItem(
                  controller: controller,
                  selectedIndex: selectedIndex,
                  index: 5,
                  icon: Icons.notifications_outlined,
                  activeIcon: Icons.notifications,
                  label: 'Thong bao'),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerNavItem extends StatelessWidget {
  const _CustomerNavItem({
    required this.controller,
    required this.selectedIndex,
    required this.index,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final CustomerHomeController controller;
  final int selectedIndex;
  final int index;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isActive = selectedIndex == index;
    return GestureDetector(
      onTap: () => controller.changePage(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 52,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.accent : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? AppColors.accent : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
