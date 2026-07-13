import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/field_model.dart';
import 'package:flutter/material.dart';

class FieldDescriptionCard extends StatelessWidget {
  final FieldModel field;

  const FieldDescriptionCard({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    final description = field.description;
    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }

    return _InfoCard(
      icon: Icons.description_outlined,
      title: 'Mo ta',
      child: Text(
        description,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}

class FieldAmenitiesCard extends StatelessWidget {
  final FieldModel field;

  const FieldAmenitiesCard({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    final amenities = field.amenities ?? const <String>[];
    if (amenities.isEmpty) {
      return const SizedBox.shrink();
    }

    return _InfoCard(
      icon: Icons.list_alt,
      title: 'Tien ich',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: amenities.map((amenity) => _AmenityChip(amenity)).toList(),
      ),
    );
  }
}

class FieldImagesSummaryCard extends StatelessWidget {
  final FieldModel field;

  const FieldImagesSummaryCard({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    final images = field.images ?? const <String>[];
    return _InfoCard(
      icon: Icons.image_outlined,
      title: 'Hinh anh',
      child: Text(
        images.isEmpty ? 'Chua co hinh anh san' : '${images.length} hinh anh',
        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final String label;

  const _AmenityChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: AppColors.secondary,
      side: BorderSide.none,
      labelStyle: const TextStyle(
        fontSize: 12,
        color: AppColors.textPrimary,
      ),
    );
  }
}
