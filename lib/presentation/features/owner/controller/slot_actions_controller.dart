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
    try {
      await ownerRepository.deleteOwnerSlot(slotId);
      Get.snackbar('Thành công', 'Đã xoá slot',
          snackPosition: SnackPosition.TOP);
      return true;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xoá slot. Có thể slot đang được đặt.',
          snackPosition: SnackPosition.TOP);
      return false;
    }
  }

  Future<int> deleteSlots(Iterable<String> slotIds) async {
    var deletedCount = 0;
    for (final slotId in slotIds) {
      try {
        await ownerRepository.deleteOwnerSlot(slotId);
        deletedCount++;
      } catch (_) {
        // Continue deleting other selected slots; summary snackbar is shown below.
      }
    }

    if (deletedCount > 0) {
      Get.snackbar(
        'ThÃ nh cÃ´ng',
        'ÄÃ£ xoÃ¡ $deletedCount slot',
        snackPosition: SnackPosition.TOP,
      );
    } else {
      Get.snackbar(
        'Lá»—i',
        'KhÃ´ng thá»ƒ xoÃ¡ cÃ¡c slot Ä‘Ã£ chá»n',
        snackPosition: SnackPosition.TOP,
      );
    }
    return deletedCount;
  }
}
