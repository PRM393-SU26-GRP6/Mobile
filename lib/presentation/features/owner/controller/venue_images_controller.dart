import 'package:exe101/domain/models/venue_image_model.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:exe101/domain/repositories/owner_management_repository.dart';
import 'package:exe101/presentation/features/customer/controller/venue_controller.dart';
import 'package:exe101/presentation/features/customer/controller/venue_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class VenueImagesController extends GetxController {
  final OwnerManagementRepository ownerRepository;
  final ImagePicker _picker = ImagePicker();

  VenueImagesController({required this.ownerRepository});

  /// Venue được khởi tạo trong onInit từ Get.arguments.
  /// GetX đảm bảo onInit chạy trước build(), nên late final không vấn đề.
  late final VenueModel venue;

  // --- reactive state ---
  final images = <VenueImageDto>[].obs;
  final isLoading = false.obs;
  final isUploading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is VenueModel) {
      venue = args;
    } else if (args is Map) {
      final m = args;
      venue = VenueModel(
        id: m['venueId']?.toString() ?? '',
        venueName: m['venueName']?.toString(),
      );
    } else {
      venue = VenueModel(id: '', venueName: 'Sân');
    }
    loadImages();
  }

  Future<void> loadImages() async {
    if (venue.id.isEmpty) {
      errorMessage.value = 'Không có ID sân';
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final list = await ownerRepository.getVenueImages(
        venueId: venue.id,
        existingUrls: venue.images,
      );
      debugPrint('[VenueImages] loadImages: loaded ${list.length} images');
      images.assignAll(list);
    } catch (e, stack) {
      debugPrint('[VenueImages] loadImages error: $e\n$stack');
      errorMessage.value = 'Không thể tải danh sách ảnh';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndUploadImages() async {
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 85);
      if (picked.isEmpty) return;

      debugPrint('[VenueImages] pickAndUpload: ${picked.length} images selected');
      isUploading.value = true;
      try {
        final result = await ownerRepository.uploadVenueImages(
          venueId: venue.id,
          files: picked,
        );
        debugPrint(
            '[VenueImages] upload result: ${result?.length ?? 0} URLs returned');
        Get.snackbar(
          'Thành công',
          'Đã tải lên ${picked.length} ảnh.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        await loadImages();

        // Refresh customer venue list so new images appear on home screen.
        if (Get.isRegistered<VenueController>()) {
          Get.find<VenueController>().refreshVenues();
        }
        // Refresh venue detail if user is currently viewing it.
        if (Get.isRegistered<VenueDetailController>()) {
          Get.find<VenueDetailController>().refreshVenue();
        }
      } catch (e, stack) {
        debugPrint('[VenueImages] upload error: $e\n$stack');
        Get.snackbar(
          'Lỗi',
          'Không thể tải ảnh lên: ${e.toString()}',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
      } finally {
        isUploading.value = false;
      }
    } catch (e, stack) {
      debugPrint('[VenueImages] picker error: $e\n$stack');
      Get.snackbar(
        'Lỗi',
        'Không thể truy cập thư viện ảnh. Kiểm tra quyền truy cập ảnh trong Cài đặt.',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> deleteImage(VenueImageDto image) async {
    final imageId = image.resolvedImageId;
    if (imageId == null || imageId.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Không tìm thấy ID ảnh để xoá. Có thể BE chưa cung cấp id qua endpoint này.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    try {
      await ownerRepository.deleteVenueImage(
        venueId: venue.id,
        imageId: imageId,
      );
      images.removeWhere((e) => e.resolvedImageId == image.resolvedImageId);
      Get.snackbar('Thành công', 'Đã xoá ảnh',
          snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xoá ảnh',
          snackPosition: SnackPosition.TOP);
    }
  }

  Future<void> confirmDeleteImage(VenueImageDto image) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Xoá ảnh?'),
        content: const Text('Ảnh sẽ bị xoá vĩnh viễn khỏi sân.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (result == true) {
      await deleteImage(image);
    }
  }
}
