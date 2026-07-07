import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/venue_image_model.dart';
import 'package:flutter/material.dart';

/// Tile hiển thị 1 ảnh venue dạng grid + nút xoá.
class VenueImageTile extends StatelessWidget {
  final VenueImageDto image;
  final VoidCallback onDelete;

  const VenueImageTile({
    super.key,
    required this.image,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final url = image.urlOrEmpty;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            url.isEmpty
                ? Container(
                    color: AppColors.secondary,
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.secondary,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: AppColors.secondary,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                  ),
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: image.resolvedImageId == null ? null : onDelete,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: image.resolvedImageId == null
                        ? Colors.grey.withValues(alpha: 0.7)
                        : Colors.red.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    image.resolvedImageId == null
                        ? Icons.info_outline
                        : Icons.delete_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
