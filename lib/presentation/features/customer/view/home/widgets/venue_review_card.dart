import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/review_model.dart';
import 'package:exe101/presentation/features/customer/shared/customer_helpers.dart';
import 'package:flutter/material.dart';

class VenueReviewCard extends StatelessWidget {
  final ReviewModel review;

  const VenueReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final stars = review.rating.clamp(0, 5);
    final initial = (review.userName?.trim().isNotEmpty ?? false)
        ? review.userName!.trim()[0].toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName ?? 'Ng뿯ƽ뿯ẽi d뿯½ng 뿯ẽn danh',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < stars ? Icons.star : Icons.star_border,
                          size: 14,
                          color: Colors.amber,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              if (review.createdAt != null)
                Text(
                  formatDateVN(review.createdAt!),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
