import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/slot_filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showSlotFilterSheet(
  BuildContext context,
  SlotFilterController controller,
) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lọc danh sách slot',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),
              const Text('Trạng thái',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: const {
                  'All': 'Tất cả',
                  'Available': 'Trống',
                  'Booked': 'Đã đặt',
                  'Locked': 'Đã khóa',
                  'Pending': 'Chờ xử lý',
                }.entries.map((entry) {
                  return ChoiceChip(
                    label: Text(entry.value),
                    selected: controller.status.value == entry.key,
                    onSelected: (_) => controller.status.value = entry.key,
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              const Text('Sắp xếp',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<SlotSortOrder>(
                initialValue: controller.sortOrder.value,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(
                    value: SlotSortOrder.newest,
                    child: Text('Ngày mới trước'),
                  ),
                  DropdownMenuItem(
                    value: SlotSortOrder.oldest,
                    child: Text('Ngày cũ trước'),
                  ),
                  DropdownMenuItem(
                    value: SlotSortOrder.timeAscending,
                    child: Text('Giờ bắt đầu tăng dần'),
                  ),
                  DropdownMenuItem(
                    value: SlotSortOrder.priceAscending,
                    child: Text('Giá thấp đến cao'),
                  ),
                  DropdownMenuItem(
                    value: SlotSortOrder.priceDescending,
                    child: Text('Giá cao đến thấp'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) controller.sortOrder.value = value;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: controller.clear,
                    child: const Text('Đặt lại'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    onPressed: Get.back,
                    icon: const Icon(Icons.check),
                    label: const Text('Áp dụng'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
