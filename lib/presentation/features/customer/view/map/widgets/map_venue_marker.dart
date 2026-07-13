import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MapVenueMarker extends StatelessWidget {
  const MapVenueMarker({
    super.key,
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: isSelected ? 4 : 2),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
        ),
        child: const Icon(Icons.sports_soccer, color: Colors.white, size: 24),
      ),
    );
  }
}
