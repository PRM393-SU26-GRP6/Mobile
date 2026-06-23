import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:exe101/presentation/features/customer/controller/venue_detail_controller.dart';
import 'package:exe101/presentation/features/customer/view/booking/booking_confirm_dialog.dart';
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
                  const SizedBox(height: 100),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(Get.context!).padding.top + 8,
              left: 12,
              right: 12,
              child: _TopNav(controller: controller),
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
                  itemCount: images.length,
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
        if (images.length > 1)
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${images.length} ảnh',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
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
          _buildInfoRow(
              Icons.location_on_outlined, venue.address ?? 'Không có địa chỉ'),
          if (venue.phoneContact != null)
            _buildInfoRow(Icons.phone_outlined, venue.phoneContact!),
          if (venue.openingHours != null)
            _buildInfoRow(Icons.access_time, venue.openingHours!),
          if (venue.description != null) ...[
            const SizedBox(height: 12),
            Text(
              venue.description!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          const Divider(color: AppColors.inputBorder, height: 1),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style:
                  const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
        ],
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
                return Obx(() => _FieldCard(
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
                        _isSameDay(date, controller.selectedDate.value!);
                    return _DateChip(
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
            return _TimeSlotGrid(controller: controller);
          }),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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

class _TopNav extends StatelessWidget {
  final dynamic controller;
  const _TopNav({required this.controller});

  @override
  Widget build(BuildContext context) {
    final venueName = controller.venue.value?.venueName ?? '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              venueName,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  final FootballFieldDto field;
  final bool isSelected;
  final VoidCallback onTap;

  const _FieldCard({
    required this.field,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${field.pricePerHour?.toStringAsFixed(0) ?? '0'}đ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        isSelected ? AppColors.accent : AppColors.textPrimary,
                  ),
                ),
                const Text(
                  '/giờ',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSlotGrid extends StatelessWidget {
  final VenueDetailController controller;

  const _TimeSlotGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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

      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: slots.map((slot) {
          return Obx(() => _SlotChip(
                slot: slot,
                isSelected: controller.selectedSlotIds.contains(slot.slotId),
                onTap: () {
                  if (slot.isAvailable) {
                    controller.toggleSlot(slot.slotId);
                  }
                },
              ));
        }).toList(),
      );
    });
  }
}

class _SlotChip extends StatelessWidget {
  final TimeSlotDto slot;
  final bool isSelected;
  final VoidCallback onTap;

  const _SlotChip({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final available = slot.isAvailable;

    return GestureDetector(
      onTap: available ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent
              : available
                  ? AppColors.secondary
                  : Colors.grey.shade800.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : available
                    ? AppColors.inputBorder
                    : Colors.grey.shade700,
          ),
        ),
        child: Column(
          children: [
            Text(
              slot.timeRange,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : available
                        ? AppColors.textPrimary
                        : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${slot.price.toStringAsFixed(0)}đ',
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.8)
                    : available
                        ? AppColors.textSecondary
                        : Colors.grey.shade700,
              ),
            ),
            if (!available)
              Text(
                'Đã đặt',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateChip({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const dayNames = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final isToday = _isToday(date);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 64,
        height: 80,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.secondary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : isToday
                    ? AppColors.accent
                    : AppColors.inputBorder,
            width: isSelected || isToday ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayNames[date.weekday - 1],
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'T${date.month}',
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.9)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
