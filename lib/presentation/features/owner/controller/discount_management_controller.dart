import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/discount_model.dart';
import 'package:get/get.dart';

class DiscountManagementController extends GetxController {
  final ApiService apiService;

  final discounts = <DiscountDto>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  DiscountManagementController({required this.apiService});

  @override
  void onInit() {
    super.onInit();
    loadDiscounts();
  }

  Future<void> loadDiscounts() async {
    try {
      isLoading.value = true;
      error.value = '';
      final list = await (apiService as ApiServiceImpl).getOwnerDiscounts();
      discounts.assignAll(list);
    } catch (e) {
      error.value = 'Không thể tải danh sách khuyến mãi';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createDiscount(DiscountDto discount) async {
    final success =
        await (apiService as ApiServiceImpl).createDiscount(discount);
    if (success) {
      loadDiscounts();
    }
    return success;
  }

  Future<bool> updateDiscount(String id, DiscountDto discount) async {
    final success =
        await (apiService as ApiServiceImpl).updateDiscount(id, discount);
    if (success) {
      loadDiscounts();
    }
    return success;
  }

  Future<bool> toggleDiscountStatus(String id) async {
    final success =
        await (apiService as ApiServiceImpl).toggleDiscountStatus(id);
    if (success) {
      // Optimitic update
      final index = discounts.indexWhere((d) => d.discountId == id);
      if (index != -1) {
        final old = discounts[index];
        final updated = DiscountDto(
          discountId: old.discountId,
          ownerId: old.ownerId,
          fieldId: old.fieldId,
          code: old.code,
          name: old.name,
          discountType: old.discountType,
          value: old.value,
          minBookingAmount: old.minBookingAmount,
          maxDiscountAmount: old.maxDiscountAmount,
          usageLimit: old.usageLimit,
          usedCount: old.usedCount,
          startDate: old.startDate,
          endDate: old.endDate,
          isActive: !old.isActive,
        );
        discounts[index] = updated;
      }
    }
    return success;
  }

  Future<bool> deleteDiscount(String id) async {
    final success = await (apiService as ApiServiceImpl).deleteDiscount(id);
    if (success) {
      discounts.removeWhere((d) => d.discountId == id);
    }
    return success;
  }
}
