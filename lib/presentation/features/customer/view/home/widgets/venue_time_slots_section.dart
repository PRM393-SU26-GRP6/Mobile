import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/venue_detail_controller.dart';
import 'package:exe101/presentation/features/customer/shared/customer_helpers.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/venue_date_chip.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/venue_slot_grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VenueTimeSlotsSection extends StatelessWidget {
  const VenueTimeSlotsSection({required this.controller, super.key});

  final VenueDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Chọn ngày',
            isLoading: controller.isLoadingSlots,
          ),
          const SizedBox(height: 12),
          Obx(() {
            final dates = controller.availableDates;
            if (!controller.isLoadingSlots.value && dates.isEmpty) {
              return const _HintText('Sân chưa có khung giờ nào');
            }
            return SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final date = dates[index];
                  return Obx(
                    () => VenueDateChip(
                      date: date,
                      isSelected: controller.selectedDate.value != null &&
                          isSameDay(date, controller.selectedDate.value!),
                      onTap: () => controller.selectDate(date),
                    ),
                  );
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
              Obx(
                () => controller.selectedSlotIds.isEmpty
                    ? const SizedBox.shrink()
                    : TextButton(
                        onPressed: controller.clearSelectedSlots,
                        child: const Text('Bỏ chọn'),
                      ),
              ),
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
              return const _HintText('Vui lòng chọn ngày để xem giờ');
            }
            if (controller.slotsForSelectedDate.isEmpty) {
              return const _HintText('Ngày này không còn khung giờ trống');
            }
            return VenueSlotGrid(controller: controller);
          }),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.isLoading});

  final String title;
  final RxBool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Obx(
          () => isLoading.value
              ? const SizedBox.square(
                  dimension: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _HintText extends StatelessWidget {
  const _HintText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
    );
  }
}
