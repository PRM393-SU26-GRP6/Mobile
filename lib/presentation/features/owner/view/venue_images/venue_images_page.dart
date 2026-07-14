import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/venue_images_controller.dart';
import 'package:exe101/presentation/features/owner/view/venue_images/widgets/venue_image_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VenueImagesPage extends StatelessWidget {
  const VenueImagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VenueImagesController>();

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Obx(() {
          return Text(
            'Ảnh - ${controller.venue.venueName ?? 'Sân'}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          );
        }),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadImages,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.images.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.images.isEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.loadImages,
          );
        }

        if (controller.images.isEmpty) {
          return _EmptyState(onAdd: controller.pickAndUploadImages);
        }

        return RefreshIndicator(
          onRefresh: controller.loadImages,
          color: AppColors.primary,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: controller.images.length,
            itemBuilder: (context, index) {
              final image = controller.images[index];
              return VenueImageTile(
                image: image,
                onDelete: () => controller.confirmDeleteImage(image),
              );
            },
          ),
        );
      }),
      floatingActionButton: Obx(() {
        if (controller.isUploading.value) {
          return const FloatingActionButton(
            onPressed: null,
            backgroundColor: AppColors.primary,
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          );
        }
        return FloatingActionButton.extended(
          onPressed: controller.pickAndUploadImages,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_a_photo),
          label: const Text('Thêm ảnh'),
        );
      }),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.image_outlined,
              size: 64,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Chưa có ảnh nào',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Bấm nút "Thêm ảnh" để tải ảnh lên cho sân',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Thêm ảnh đầu tiên'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
