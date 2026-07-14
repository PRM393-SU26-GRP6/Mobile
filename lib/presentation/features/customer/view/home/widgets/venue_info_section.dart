import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/venue_detail_controller.dart';
import 'package:exe101/presentation/features/customer/view/booking/widgets/booking_labeled_info_row.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/venue_chat_launcher.dart';
import 'package:flutter/material.dart';

class VenueInfoSection extends StatelessWidget {
  const VenueInfoSection({required this.controller, super.key});

  final VenueDetailController controller;

  @override
  Widget build(BuildContext context) {
    final venue = controller.venue.value!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  venue.venueName ?? 'Cụm sân',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (venue.averageRating != null) ...[
                const Icon(Icons.star, size: 18, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  venue.averageRating!.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (venue.totalReviews != null)
                  Text(
                    ' (${venue.totalReviews})',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          LabeledInfoRow(
            icon: Icons.location_on_outlined,
            text: venue.address ?? 'Không có địa chỉ',
          ),
          if (venue.phoneContact != null)
            LabeledInfoRow(
              icon: Icons.phone_outlined,
              text: venue.phoneContact!,
            ),
          if (venue.openingHours != null)
            LabeledInfoRow(
              icon: Icons.access_time,
              text: venue.openingHours!,
            ),
          if (venue.ownerName != null)
            LabeledInfoRow(
              icon: Icons.person_outline,
              text: 'Chủ sân: ${venue.ownerName}',
            ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.inputBorder, height: 1),
          const SizedBox(height: 16),
          _ChatButton(controller: controller),
        ],
      ),
    );
  }
}

class _ChatButton extends StatelessWidget {
  const _ChatButton({required this.controller});

  final VenueDetailController controller;

  @override
  Widget build(BuildContext context) {
    final venue = controller.venue.value;
    if (venue == null) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => startChatWithVenueOwner(
          venue,
          onVenueUpdated: (updated) => controller.venue.value = updated,
        ),
        icon: const Icon(Icons.chat_bubble_outline, size: 20),
        label: Text(
          venue.ownerId != null ? 'Nhắn tin chủ sân' : 'Liên hệ chủ sân',
        ),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
