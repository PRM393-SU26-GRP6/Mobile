import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/review_model.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:flutter/material.dart';

class VenueFieldCard extends StatelessWidget {
  final FootballFieldDto field;
  final bool isSelected;
  final VoidCallback onTap;
  final FieldRatingDto? rating;
  final VoidCallback? onLoadRating;

  const VenueFieldCard({
    super.key,
    required this.field,
    required this.isSelected,
    required this.onTap,
    this.rating,
    this.onLoadRating,
  });

  @override
  Widget build(BuildContext context) {
    // Trigger a one-shot lazy fetch the first time the card is built.
    // The controller is responsible for caching and dedup.
    if (rating == null && onLoadRating != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onLoadRating?.call();
      });
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.15)
              : AppColors.secondary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.inputBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.2)
                    : AppColors.inputBorder,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.sports_soccer,
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.fieldName ?? 'Sân',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? AppColors.accent : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          field.fieldTypeLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      if (rating != null && rating!.totalReviews > 0) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.star, size: 13, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          rating!.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '(${rating!.totalReviews})',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
