import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/core/constant/app_strings.dart';
import 'package:flutter/material.dart';

class OwnerNavBar extends StatelessWidget {
  final int pendingCount;
  final int notificationCount;
  final int selectedIndex;
  final VoidCallback onFieldsTap;
  final VoidCallback onBookingsTap;
  final VoidCallback onMessagesTap;
  final VoidCallback onRevenueTap;
  final VoidCallback onNotificationsTap;

  const OwnerNavBar({
    super.key,
    required this.pendingCount,
    required this.notificationCount,
    required this.selectedIndex,
    required this.onFieldsTap,
    required this.onBookingsTap,
    required this.onMessagesTap,
    required this.onRevenueTap,
    required this.onNotificationsTap,
  });

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
              Expanded(
                child: _NavButton(
                  icon: Icons.stadium,
                  label: 'Sân',
                  isSelected: selectedIndex == 0,
                  onTap: onFieldsTap,
                ),
              ),
              Expanded(
                child: _NavButton(
                  icon: Icons.calendar_today,
                  label: AppStrings.navigation.bookings,
                  isSelected: selectedIndex == 1,
                  badge: pendingCount,
                  onTap: onBookingsTap,
                ),
              ),
              Expanded(
                child: _NavButton(
                  icon: Icons.bar_chart,
                  label: AppStrings.navigation.revenue,
                  isSelected: selectedIndex == 2,
                  onTap: onRevenueTap,
                ),
              ),
              Expanded(
                child: _NavButton(
                  icon: Icons.chat_bubble_outline,
                  label: AppStrings.navigation.messages,
                  isSelected: selectedIndex == 3,
                  onTap: onMessagesTap,
                ),
              ),
              Expanded(
                child: _NavButton(
                  icon: Icons.notifications_outlined,
                  label: AppStrings.navigation.notifications,
                  isSelected: selectedIndex == 4,
                  badge: notificationCount,
                  onTap: onNotificationsTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final int badge;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                if (badge > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badge > 9 ? '9+' : '$badge',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
