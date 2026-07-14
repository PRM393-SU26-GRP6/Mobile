import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/repositories/owner_management_repository.dart';
import 'package:get/get.dart';

/// Controller xử lý các thao tác đơn lẻ trên slot:
/// toggle status (Available/Locked), update (giá/trạng thái), delete.
///
/// Tách riêng khỏi [SlotManagementController] để controller chính
/// không vượt quá 200 dòng theo AGENTS.md.
class SlotActionsController extends GetxController {
  final ApiServiceImpl apiService;
  final OwnerManagementRepository ownerRepository;

  SlotActionsController({
    required this.apiService,
    required this.ownerRepository,
  });

  final isDeleting = false.obs;
  final deletingSlotIds = <String>[].obs;

  int get deletingCount => deletingSlotIds.length;

  Future<bool> toggleSlotStatus(String slotId, bool isActive) async {
    try {
      final status = isActive ? 'Available' : 'Locked';
      await apiService.updateSlotStatus(slotId, status);
      Get.snackbar(
        'Thành công',
        isActive ? 'Đã mở slot' : 'Đã khóa slot',
        snackPosition: SnackPosition.TOP,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể cập nhật trạng thái slot: $e',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
      return false;
    }
  }

  /// Cập nhật 1 slot (giá/trạng thái) qua owner API.
  Future<bool> updateSlot({
    required String slotId,
    double? price,
    String? status,
  }) async {
    try {
      await ownerRepository.updateOwnerSlot(
        slotId: slotId,
        price: price,
        status: status,
      );
      Get.snackbar('Thành công', 'Đã cập nhật slot',
          snackPosition: SnackPosition.TOP);
      return true;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật slot',
          snackPosition: SnackPosition.TOP);
      return false;
    }
  }

  /// Xoá 1 slot.
  Future<bool> deleteSlot(String slotId) async {
    if (isDeleting.value || slotId.isEmpty) return false;
    _beginDeleting([slotId]);
    try {
      await ownerRepository.deleteOwnerSlot(slotId);
      Get.snackbar('Thành công', 'Đã xoá slot',
          snackPosition: SnackPosition.TOP);
      return true;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xoá slot. Có thể slot đang được đặt.',
          snackPosition: SnackPosition.TOP);
      return false;
    } finally {
      _finishDeleting();
    }
  }

  Future<int> deleteSlots(Iterable<String> slotIds) async {
    if (isDeleting.value) return 0;
    final ids = slotIds.where((id) => id.isNotEmpty).toSet().toList();
    if (ids.isEmpty) return 0;

    _beginDeleting(ids);
    var deletedCount = 0;
    try {
      for (final slotId in ids) {
        try {
          await ownerRepository.deleteOwnerSlot(slotId);
          deletedCount++;
        } catch (_) {
          // Continue deleting other selected slots; summary is shown below.
        }
      }

      if (deletedCount > 0) {
        Get.snackbar(
          'Thành công',
          'Đã xoá $deletedCount khung giờ',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          'Lỗi',
          'Không thể xoá các khung giờ đã chọn',
          snackPosition: SnackPosition.TOP,
        );
      }
      return deletedCount;
    } finally {
      _finishDeleting();
    }
  }

  void _beginDeleting(Iterable<String> slotIds) {
    deletingSlotIds.assignAll(slotIds);
    isDeleting.value = true;
  }

  void _finishDeleting() {
    isDeleting.value = false;
    deletingSlotIds.clear();
  }
}
