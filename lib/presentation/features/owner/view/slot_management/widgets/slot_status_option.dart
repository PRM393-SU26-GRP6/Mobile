import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SlotStatusOption extends StatelessWidget {
  const SlotStatusOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(label),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
