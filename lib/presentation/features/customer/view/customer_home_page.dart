import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/view/home/home_page.dart';
import 'package:exe101/presentation/features/customer/view/map/map_page.dart';
import 'package:exe101/presentation/features/customer/view/cart/cart_page.dart';
import 'package:exe101/presentation/features/customer/view/orders/orders_page.dart';
import 'package:exe101/presentation/features/customer/view/messages/messages_page.dart';
import 'package:exe101/presentation/features/customer/view/notifications/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(_CustomerHomeController());

    return Scaffold(
      body: Obx(() => controller.pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(() => _buildBottomNav(controller)),
    );
  }

  Widget _buildBottomNav(_CustomerHomeController controller) {
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
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Trang chủ',
                isActive: controller.currentIndex.value == 0,
                onTap: () => controller.changePage(0),
              ),
              _NavItem(
                icon: Icons.map_outlined,
                activeIcon: Icons.map,
                label: 'Bản đồ',
                isActive: controller.currentIndex.value == 1,
                onTap: () => controller.changePage(1),
              ),
              _NavItem(
                icon: Icons.shopping_cart_outlined,
                activeIcon: Icons.shopping_cart,
                label: 'Giỏ hàng',
                isActive: controller.currentIndex.value == 2,
                onTap: () => controller.changePage(2),
              ),
              _NavItem(
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long,
                label: 'Đơn hàng',
                isActive: controller.currentIndex.value == 3,
                onTap: () => controller.changePage(3),
              ),
              _NavItem(
                icon: Icons.chat_bubble_outline,
                activeIcon: Icons.chat_bubble,
                label: 'Tin nhắn',
                isActive: controller.currentIndex.value == 4,
                onTap: () => controller.changePage(4),
              ),
              _NavItem(
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications,
                label: 'Thông báo',
                isActive: controller.currentIndex.value == 5,
                onTap: () => controller.changePage(5),
              ),
              // Removed explicit logout from bottom nav - logout is available in header
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerHomeController extends GetxController {
  final currentIndex = 0.obs;

  final pages = [
    const HomePage(),
    const MapPage(),
    const CartPage(),
    const OrdersPage(),
    const MessagesPage(),
    const NotificationsPage(),
  ];

  void changePage(int index) {
    currentIndex.value = index;
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
