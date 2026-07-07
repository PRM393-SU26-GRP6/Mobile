import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class OwnerNavBar extends StatelessWidget {
  final int pendingCount;
  final VoidCallback onFieldsTap;
  final VoidCallback onBookingsTap;
  final VoidCallback onRevenueTap;

  const OwnerNavBar({
    super.key,
    required this.pendingCount,
    required this.onFieldsTap,
    required this.onBookingsTap,
    required this.onRevenueTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _NavButton(
                  icon: Icons.stadium,
                  label: 'Sân',
                  isSelected: true,
                  onTap: onFieldsTap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NavButton(
                  icon: Icons.calendar_today,
                  label: 'Đặt sân',
                  isSelected: false,
                  badge: pendingCount,
                  onTap: onBookingsTap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NavButton(
                  icon: Icons.bar_chart,
                  label: 'Doanh thu',
                  isSelected: false,
                  onTap: onRevenueTap,
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
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
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
