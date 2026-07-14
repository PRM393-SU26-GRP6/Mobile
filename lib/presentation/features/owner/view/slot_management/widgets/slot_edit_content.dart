import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_status_option.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SlotEditResult {
  const SlotEditResult({required this.price, required this.status});

  final double price;
  final String status;
}

class SlotEditContent extends StatefulWidget {
  const SlotEditContent({
    super.key,
    required this.slot,
    required this.priceController,
  });

  final TimeSlotDto slot;
  final TextEditingController priceController;

  @override
  State<SlotEditContent> createState() => _SlotEditContentState();
}

class _SlotEditContentState extends State<SlotEditContent> {
  static const options = <String, String>{
    'Available': 'Trống (mở bán)',
    'Locked': 'Khóa (tạm ẩn)',
  };

  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    final status = widget.slot.slotStatus ?? 'Available';
    selectedStatus = options.containsKey(status) ? status : 'Available';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Sửa khung giờ ${widget.slot.timeRange}',
        style: const TextStyle(fontSize: 16),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ngày: ${widget.slot.selectedDate}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            const Text(
              'Giá khung giờ (VNĐ)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: widget.priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Nhập giá',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Trạng thái',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            for (final option in options.entries)
              SlotStatusOption(
                label: option.value,
                selected: option.key == selectedStatus,
                onTap: () => setState(() => selectedStatus = option.key),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Hủy')),
        ElevatedButton(onPressed: _submit, child: const Text('Lưu')),
      ],
    );
  }

  void _submit() {
    final price = double.tryParse(widget.priceController.text.trim());
    if (price == null || price <= 0) {
      Get.snackbar('Lỗi', 'Giá phải là số dương');
      return;
    }
    Get.back(result: SlotEditResult(price: price, status: selectedStatus));
  }
}
