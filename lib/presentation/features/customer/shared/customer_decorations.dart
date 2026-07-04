import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

BoxDecoration cardShadowDecoration({
  Color? color,
  double radius = 12,
  double blurRadius = 10,
  Offset offset = const Offset(0, 2),
}) {
  return BoxDecoration(
    color: color ?? Colors.white,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: blurRadius,
        offset: offset,
      ),
    ],
  );
}

BoxDecoration softShadowDecoration({
  Color? color,
  double radius = 16,
  double blurRadius = 8,
  Offset offset = const Offset(0, 2),
}) {
  return BoxDecoration(
    color: color ?? Colors.white,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: blurRadius,
        offset: offset,
      ),
    ],
  );
}

BoxDecoration gradientButtonDecoration({
  double radius = 12,
  List<Color>? colors,
}) {
  return BoxDecoration(
    gradient: LinearGradient(
      colors: colors ??
          [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
