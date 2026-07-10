import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/discount_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiscountManagementPage extends StatelessWidget {
  const DiscountManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DiscountManagementController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Quản lý Khuyến mãi'),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.primary),
            onPressed: () {
              Get.toNamed(AppPages.ownerDiscountEditor);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.discounts.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.error.value, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadDiscounts(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (controller.discounts.isEmpty) {
          return const Center(
            child: Text(
              'Chưa có mã khuyến mãi nào',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadDiscounts,
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.discounts.length,
            itemBuilder: (context, index) {
              final discount = controller.discounts[index];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Get.toNamed(AppPages.ownerDiscountEditor, arguments: discount);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              discount.code ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Switch(
                              value: discount.isActive,
                              activeColor: AppColors.primary,
                              onChanged: (val) {
                                controller.toggleDiscountStatus(discount.discountId);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          discount.name ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.local_offer_outlined, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              discount.discountType == 'Percentage'
                                  ? 'Giảm ${discount.value.toStringAsFixed(0)}%'
                                  : 'Giảm ${discount.value.toStringAsFixed(0)}đ',
                              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                            const Spacer(),
                            const Icon(Icons.confirmation_number_outlined, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'Đã dùng: ${discount.usedCount}/${discount.usageLimit}',
                              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Get.dialog(
                                AlertDialog(
                                  title: const Text('Xác nhận xóa'),
                                  content: const Text('Bạn có chắc chắn muốn xóa mã này?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: const Text('Hủy'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                        controller.deleteDiscount(discount.discountId);
                                      },
                                      child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text(
                              'Xóa',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
