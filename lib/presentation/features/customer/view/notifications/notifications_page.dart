import 'package:dio/dio.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/notification_model.dart';
import 'package:exe101/domain/repositories/user_repository.dart';
import 'package:exe101/presentation/features/customer/controller/notification_controller.dart';
import 'package:exe101/presentation/features/customer/view/notifications/widgets/mark_all_read_dialog.dart';
import 'package:exe101/presentation/features/customer/view/notifications/widgets/notification_filter_chip.dart';
import 'package:exe101/presentation/features/customer/view/notifications/widgets/notification_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsPage extends StatelessWidget {
  final bool showBackButton;

  const NotificationsPage({
    super.key,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = _getController();

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(controller),
            _buildFilterBar(controller),
            Expanded(
              child: Obx(() => _buildContent(controller)),
            ),
          ],
        ),
      ),
    );
  }

  NotificationController _getController() {
    if (Get.isRegistered<NotificationController>()) {
      return Get.find<NotificationController>();
    }

    if (!Get.isRegistered<UserRepository>()) {
      final apiService = Get.isRegistered<ApiServiceImpl>()
          ? Get.find<ApiServiceImpl>()
          : ApiServiceImpl(Dio());
      Get.put<UserRepository>(UserRepository(apiService: apiService));
    }

    return Get.put(NotificationController(
      userRepository: Get.find<UserRepository>(),
    ));
  }

  Widget _buildHeader(NotificationController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        children: [
          if (showBackButton) ...[
            IconButton(
              onPressed: Get.back,
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
          ],
          const Expanded(
            child: Text(
              'Thông báo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: -0.02,
              ),
            ),
          ),
          Obx(() {
            if (controller.unreadCount.value > 0) {
              return GestureDetector(
                onTap: () => showMarkAllReadDialog(controller),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEAEAEA)),
                  ),
                  child: const Text(
                    'Đọc tất cả',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildFilterBar(NotificationController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Obx(() {
        return Row(
          children: [
            NotificationFilterChip(
              label: 'Tất cả',
              isSelected: !controller.showUnreadOnly.value,
              onTap: () {
                if (controller.showUnreadOnly.value) {
                  controller.toggleUnreadOnly();
                }
              },
            ),
            const SizedBox(width: 8),
            NotificationFilterChip(
              label: 'Chưa đọc',
              isSelected: controller.showUnreadOnly.value,
              onTap: () {
                if (!controller.showUnreadOnly.value) {
                  controller.toggleUnreadOnly();
                }
              },
              showBadge: controller.unreadCount.value > 0,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildContent(NotificationController controller) {
    if (controller.isLoading.value && controller.notifications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (controller.error.value.isNotEmpty && controller.notifications.isEmpty) {
      return _buildErrorState(controller);
    }

    if (controller.notifications.isEmpty) {
      return _buildEmptyState(controller.showUnreadOnly.value);
    }

    return RefreshIndicator(
      onRefresh: controller.refreshNotifications,
      color: AppColors.primary,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.extentAfter < 200) {
            controller.loadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          itemCount: controller.notifications.length +
              (controller.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < controller.notifications.length) {
              return NotificationItem(
                notification: controller.notifications[index],
                onTap: () => _handleNotificationTap(
                    controller, controller.notifications[index]),
                onMarkRead: () => controller.markAsRead(
                    controller.notifications[index].notificationId!),
                getTimeAgo: controller.getTimeAgo,
              );
            }
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(NotificationController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEAEAEA)),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 32,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              controller.error.value,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => controller.loadNotifications(refresh: true),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Thử lại',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool unreadOnly) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEAEAEA)),
              ),
              child: Icon(
                unreadOnly
                    ? Icons.notifications_off_outlined
                    : Icons.notifications_outlined,
                size: 40,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              unreadOnly
                  ? 'Không có thông báo chưa đọc'
                  : 'Không có thông báo nào',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              unreadOnly
                  ? 'Tất cả thông báo đã được đọc'
                  : 'Các thông báo sẽ xuất hiện tại đây',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(
      NotificationController controller, NotificationModel notification) {
    if (!notification.isRead) {
      controller.markAsRead(notification.notificationId!);
    }
  }
}
