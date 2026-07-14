import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SlotOptionTile extends StatelessWidget {
  const SlotOptionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(
          label,
          style: TextStyle(
            color: destructive ? Colors.red : AppColors.textPrimary,
            fontWeight: destructive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      );
}
