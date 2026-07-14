import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/venue_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VenueImageHeader extends StatelessWidget {
  const VenueImageHeader({required this.controller, super.key});

  final VenueDetailController controller;

  @override
  Widget build(BuildContext context) {
    final images = controller.venue.value?.images ?? [];

    return Stack(
      children: [
        SizedBox(
          height: 260,
          width: double.infinity,
          child: images.isEmpty
              ? const _ImagePlaceholder()
              : PageView.builder(
                  controller: controller.imagePageController,
                  itemCount: images.length,
                  onPageChanged: controller.onImagePageChanged,
                  itemBuilder: (_, index) => Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
                  ),
                ),
        ),
        if (images.length > 1) ...[
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _ImageNavButton(
                icon: Icons.chevron_left,
                tooltip: 'Ảnh trước',
                onTap: () => controller.previousImage(images.length),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _ImageNavButton(
                icon: Icons.chevron_right,
                tooltip: 'Ảnh tiếp theo',
                onTap: () => controller.nextImage(images.length),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${controller.currentImageIndex.value + 1}/${images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) {
                  final active = index == controller.currentImageIndex.value;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white70,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.secondary,
      child: Center(
        child: Icon(
          Icons.sports_soccer,
          size: 64,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ImageNavButton extends StatelessWidget {
  const _ImageNavButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black.withValues(alpha: 0.4),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
