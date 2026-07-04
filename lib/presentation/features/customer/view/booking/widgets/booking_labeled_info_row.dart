import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LabeledInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final double iconSize;
  final double gap;
  final double bottomGap;
  final TextStyle? textStyle;

  const LabeledInfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconSize = 16,
    this.gap = 8,
    this.bottomGap = 8,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomGap),
      child: Row(
        children: [
          Icon(icon, size: iconSize, color: AppColors.textSecondary),
          SizedBox(width: gap),
          Expanded(
            child: Text(
              text,
              style: textStyle ??
                  const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
