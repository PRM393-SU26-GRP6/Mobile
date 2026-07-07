import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/venue_detail_controller.dart';
import 'package:exe101/presentation/features/customer/shared/customer_helpers.dart';
import 'package:exe101/presentation/features/customer/view/booking/booking_confirm_dialog.dart';
import 'package:exe101/presentation/features/customer/view/booking/widgets/booking_labeled_info_row.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/venue_chat_launcher.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/venue_date_chip.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/venue_field_card.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/venue_review_card.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/venue_slot_grid.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/venue_top_nav.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VenueDetailPage extends StatelessWidget {
  const VenueDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<VenueDetailController>()
        ? Get.find<VenueDetailController>()
        : Get.put(VenueDetailController(apiService: Get.find()));

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Obx(() {
        if (controller.isLoadingVenue.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }

        if (controller.venue.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  controller.error.value.isNotEmpty
                      ? controller.error.value
                      : 'Không tìm thấy sân',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageHeader(controller),
                  _buildVenueInfo(controller),
                  _buildAmenities(controller),
                  _buildFieldSelection(controller),
                  if (controller.selectedField.value != null)
                    _buildTimeSlots(controller),
                  _buildReviewsSection(controller),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(Get.context!).padding.top + 8,
              left: 12,
              right: 12,
              child: VenueTopNav(controller: controller),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomBar(controller),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildImageHeader(VenueDetailController controller) {
    final images = controller.venue.value?.images ?? [];

    return Stack(
      children: [
        SizedBox(
          height: 260,
          width: double.infinity,
          child: images.isNotEmpty
              ? PageView.builder(
                  controller: controller.imagePageController,
                  itemCount: images.length,
                  onPageChanged: controller.onImagePageChanged,
                  itemBuilder: (context, index) {
                    return Image.network(
                      images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                    );
                  },
                )
              : _buildImagePlaceholder(),
        ),
        if (images.length > 1) ...[
          // Left arrow
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _ImageNavButton(
                icon: Icons.chevron_left,
                onTap: () => controller.previousImage(images.length),
              ),
            ),
          ),
          // Right arrow
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _ImageNavButton(
                icon: Icons.chevron_right,
                onTap: () => controller.nextImage(images.length),
              ),
            ),
          ),
          // Page indicator (e.g. 1/3)
          Positioned(
            bottom: 12,
            right: 12,
            child: Obx(() => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${controller.currentImageIndex.value + 1}/${images.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                )),
          ),
          // Dot indicators
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Center(
              child: Obx(() => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(images.length, (i) {
                      final active =
                          i == controller.currentImageIndex.value;
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
                  )),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.secondary,
      child: const Center(
        child:
            Icon(Icons.sports_soccer, size: 64, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildVenueInfo(VenueDetailController controller) {
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
              text: venue.address ?? 'Không có địa chỉ'),
          if (venue.phoneContact != null)
            LabeledInfoRow(
                icon: Icons.phone_outlined, text: venue.phoneContact!),
          if (venue.openingHours != null)
            LabeledInfoRow(icon: Icons.access_time, text: venue.openingHours!),
          if (venue.ownerName != null)
            LabeledInfoRow(
                icon: Icons.person_outline,
                text: 'Chủ sân: ${venue.ownerName}'),
          const SizedBox(height: 16),
          const Divider(color: AppColors.inputBorder, height: 1),
          const SizedBox(height: 16),
          _buildChatButton(controller),
        ],
      ),
    );
  }

  Widget _buildChatButton(VenueDetailController controller) {
    final venue = controller.venue.value;
    if (venue == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => startChatWithVenueOwner(
        venue,
        onVenueUpdated: (updated) => controller.venue.value = updated,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline,
                color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              venue.ownerId != null ? 'Nhắn tin chủ sân' : 'Liên hệ chủ sân',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenities(VenueDetailController controller) {
    final amenities = controller.venue.value?.amenities ?? [];
    if (amenities.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tiện ích',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: amenities.map((a) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 14,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      a.amenityName ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.inputBorder, height: 1),
        ],
      ),
    );
  }

  Widget _buildFieldSelection(VenueDetailController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Chọn sân',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Obx(() {
                if (controller.isLoadingFields.value) {
                  return const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.isLoadingFields.value) {
              return const SizedBox(height: 80);
            }
            if (controller.fields.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Không có sân con nào',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }
            return Column(
              children: controller.fields.map((field) {
                return Obx(() => VenueFieldCard(
                      field: field,
                      isSelected:
                          controller.selectedField.value?.id == field.id,
                      onTap: () => controller.selectField(field),
                    ));
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimeSlots(VenueDetailController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Chọn ngày',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Obx(() {
                if (controller.isLoadingSlots.value) {
                  return const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final dates = controller.availableDates;
            if (!controller.isLoadingSlots.value && dates.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Sân chưa có khung giờ nào',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              );
            }
            return SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final date = dates[index];
                  return Obx(() {
                    final isSelected = controller.selectedDate.value != null &&
                        isSameDay(date, controller.selectedDate.value!);
                    return VenueDateChip(
                      date: date,
                      isSelected: isSelected,
                      onTap: () => controller.selectDate(date),
                    );
                  });
                },
              ),
            );
          }),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'Chọn giờ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Obx(() {
                if (controller.selectedSlotIds.isNotEmpty) {
                  return GestureDetector(
                    onTap: () => controller.selectedSlotIds.clear(),
                    child: const Text(
                      'Bỏ chọn',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.accent,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.isLoadingSlots.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
              );
            }
            if (controller.selectedDate.value == null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Vui lòng chọn ngày để xem giờ',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              );
            }
            final slots = controller.slotsForSelectedDate;
            if (slots.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Ngày này chưa có khung giờ',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              );
            }
            return VenueSlotGrid(controller: controller);
          }),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(VenueDetailController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Đánh giá',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Obx(() {
                if (controller.reviews.isEmpty) return const SizedBox.shrink();
                return Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      controller.reviewAverageRating.value.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${controller.reviewTotalCount.value})',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          _buildReviewsList(controller),
        ],
      ),
    );
  }

  Widget _buildReviewsList(VenueDetailController controller) {
    return Obx(() {
      if (controller.isLoadingReviews.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        );
      }

      if (controller.reviews.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.rate_review_outlined,
                  size: 20, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              Text(
                'Chưa có bài đánh giá nào',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          ...controller.reviews.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: VenueReviewCard(review: r),
              )),
          if (controller.hasMoreReviews.value)
            Obx(() => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: GestureDetector(
                    onTap: controller.isLoadingMoreReviews.value
                        ? null
                        : controller.loadMoreReviews,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: Center(
                        child: controller.isLoadingMoreReviews.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.accent,
                                ),
                              )
                            : const Text(
                                'Xem thêm đánh giá',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                )),
        ],
      );
    });
  }

  Widget _buildBottomBar(VenueDetailController controller) {
    return Obx(() {
      final slotCount = controller.selectedSlotIds.length;
      final hasSelection = slotCount > 0;

      return Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(Get.context!).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hasSelection
                        ? '$slotCount khung giờ đã chọn'
                        : 'Chọn sân và khung giờ',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (hasSelection)
                    Text(
                      '${controller.totalPrice.toStringAsFixed(0)}đ',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: hasSelection
                  ? () async {
                      final success = await BookingConfirmDialog.show(
                        slotIds: controller.selectedSlotIds.toList(),
                        totalPrice: controller.totalPrice,
                        venueName: controller.venue.value?.venueName ?? '',
                        fieldName:
                            controller.selectedField.value?.fieldName ?? '',
                        slotCount: slotCount,
                      );
                      if (success) {
                        controller.selectedSlotIds.clear();
                        if (controller.selectedField.value != null) {
                          controller
                              .loadSlots(controller.selectedField.value!.id);
                        }
                      }
                    }
                  : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  gradient: hasSelection
                      ? const LinearGradient(
                          colors: [
                            AppColors.buttonGradientStart,
                            AppColors.buttonGradientEnd,
                          ],
                        )
                      : null,
                  color: hasSelection ? null : Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Đặt sân',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: hasSelection ? Colors.white : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ImageNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ImageNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
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
    );
  }
}
