import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/slot_management_controller.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/duration_chips.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/price_slider.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_date_picker.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_info_card.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateSlotsTab extends StatelessWidget {
  final SlotManagementController controller;
  const CreateSlotsTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SlotInfoCard(
            message:
                'Tạo khung giờ hàng loạt giúp bạn nhanh chóng thiết lập lịch đặt sân cho nhiều ngày.',
            backgroundColor: Color(0xFFFCE4EC),
            borderColor: Color(0xFFF8BBD0),
            iconColor: AppColors.primary,
          ),
          const SizedBox(height: 20),
          _buildDateRangeSection(context),
          const SizedBox(height: 20),
          _buildTimeSection(),
          const SizedBox(height: 20),
          _buildDurationSection(),
          const SizedBox(height: 20),
          _buildPriceSection(),
          const SizedBox(height: 32),
          _buildCreateButton(),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeSection(BuildContext context) {
    final firstDate = DateTime.now();
    final lastDate = DateTime.now().add(const Duration(days: 365));
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(Icons.date_range, 'Khoảng ngày'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SlotDatePickerField(
                  label: 'Từ ngày',
                  value: controller.fromDate.value,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  onChanged: (d) => controller.fromDate.value = d,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.arrow_forward,
                  color: AppColors.textSecondary,
                ),
              ),
              Expanded(
                child: SlotDatePickerField(
                  label: 'Đến ngày',
                  value: controller.toDate.value,
                  firstDate: controller.fromDate.value ?? firstDate,
                  lastDate: lastDate,
                  onChanged: (d) => controller.toDate.value = d,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(Icons.access_time, 'Khung giờ hoạt động'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SlotTimePickerField(
                  value: controller.startTime.value,
                  onChanged: (t) => controller.startTime.value = t,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.remove,
                  color: AppColors.textSecondary,
                ),
              ),
              Expanded(
                child: SlotTimePickerField(
                  value: controller.endTime.value,
                  onChanged: (t) => controller.endTime.value = t,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(Icons.timer_outlined, 'Thời lượng mỗi slot'),
          const SizedBox(height: 16),
          Obx(() => DurationChips(
                availableDurations: controller.availableDurations,
                selectedDuration: controller.slotDuration.value,
                onChanged: (d) => controller.slotDuration.value = d,
              )),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(Icons.attach_money, 'Giá mỗi slot'),
          const SizedBox(height: 16),
          Obx(() => PriceSlider(
                value: controller.slotPrice.value,
                min: 50000,
                max: 500000,
                divisions: 45,
                quickPrices: const [100000, 150000, 200000, 300000],
                onChanged: (v) => controller.slotPrice.value = v,
              )),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: controller.isCreatingSlots.value
                ? null
                : () => controller.createSlots(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 4,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
            ),
            child: controller.isCreatingSlots.value
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Tạo Slots',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ));
  }
}
