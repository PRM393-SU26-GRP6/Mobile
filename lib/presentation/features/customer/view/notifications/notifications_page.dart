import 'package:dio/dio.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/notification_model.dart';
import 'package:exe101/domain/repositories/user_repository.dart';
import 'package:exe101/presentation/features/customer/controller/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

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

    // Auto-setup dependencies if not registered
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
                onTap: () => _showMarkAllReadDialog(controller),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            _FilterChip(
              label: 'Tất cả',
              isSelected: !controller.showUnreadOnly.value,
              onTap: () {
                if (controller.showUnreadOnly.value) {
                  controller.toggleUnreadOnly();
                }
              },
            ),
            const SizedBox(width: 8),
            _FilterChip(
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
          itemCount: controller.notifications.length + (controller.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < controller.notifications.length) {
              return _NotificationItem(
                notification: controller.notifications[index],
                onTap: () => _handleNotificationTap(controller, controller.notifications[index]),
                onMarkRead: () => controller.markAsRead(controller.notifications[index].notificationId!),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                unreadOnly ? Icons.notifications_off_outlined : Icons.notifications_outlined,
                size: 40,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              unreadOnly ? 'Không có thông báo chưa đọc' : 'Không có thông báo nào',
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

  void _handleNotificationTap(NotificationController controller, NotificationModel notification) {
    if (!notification.isRead) {
      controller.markAsRead(notification.notificationId!);
    }
  }

  void _showMarkAllReadDialog(NotificationController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Đánh dấu đã đọc',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Bạn có muốn đánh dấu tất cả thông báo là đã đọc?',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Hủy',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.markAllAsRead();
            },
            child: const Text(
              'Đồng ý',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showBadge;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFEAEAEA),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            if (showBadge && isSelected) ...[
              const SizedBox(width: 6),
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check,
                    size: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;
  final String Function(DateTime?) getTimeAgo;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
    required this.onMarkRead,
    required this.getTimeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? const Color(0xFFEAEAEA)
                : AppColors.primary.withValues(alpha: 0.3),
            width: notification.isRead ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title ?? 'Thông báo',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (notification.message != null && notification.message!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.message!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getTypeColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getTypeLabel(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: _getTypeColor(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        getTimeAgo(notification.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final iconData = _getNotificationIcon();
    final color = _getTypeColor();

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        iconData,
        size: 20,
        color: color,
      ),
    );
  }

  IconData _getNotificationIcon() {
    switch (notification.type?.toLowerCase()) {
      case 'booking':
        return Icons.calendar_today_outlined;
      case 'payment':
        return Icons.payment_outlined;
      case 'promotion':
        return Icons.local_offer_outlined;
      case 'system':
        return Icons.settings_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getTypeColor() {
    switch (notification.type?.toLowerCase()) {
      case 'booking':
        return const Color(0xFF0FA24A);
      case 'payment':
        return const Color(0xFF1F6C9F);
      case 'promotion':
        return const Color(0xFFE67E22);
      case 'system':
        return const Color(0xFF6B7A6D);
      default:
        return AppColors.primary;
    }
  }

  String _getTypeLabel() {
    switch (notification.type?.toLowerCase()) {
      case 'booking':
        return 'Đặt sân';
      case 'payment':
        return 'Thanh toán';
      case 'promotion':
        return 'Khuyến mãi';
      case 'system':
        return 'Hệ thống';
      default:
        return 'Thông báo';
    }
  }
}
