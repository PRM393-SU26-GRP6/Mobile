import 'package:exe101/domain/models/notification_model.dart';
import 'package:exe101/domain/repositories/user_repository.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final UserRepository userRepository;

  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final error = ''.obs;
  final unreadCount = 0.obs;
  final showUnreadOnly = false.obs;

  int _currentPage = 1;
  static const int _pageSize = 20;

  NotificationController({required this.userRepository});

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    loadUnreadCount();
  }

  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
      notifications.clear();
    }

    if (!hasMore.value) return;

    try {
      if (_currentPage == 1) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
      error.value = '';

      final result = await userRepository.getNotifications(
        unreadOnly: showUnreadOnly.value,
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      if (result.length < _pageSize) {
        hasMore.value = false;
      }

      notifications.addAll(result);
      _currentPage++;
    } catch (e) {
      error.value = 'Không thể tải thông báo';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshNotifications() async {
    await loadNotifications(refresh: true);
    await loadUnreadCount();
  }

  Future<void> loadUnreadCount() async {
    try {
      final count = await userRepository.getUnreadNotificationCount();
      unreadCount.value = count;
    } catch (_) {
      // Silently fail for unread count
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value) return;
    await loadNotifications();
  }

  Future<void> toggleUnreadOnly() async {
    showUnreadOnly.value = !showUnreadOnly.value;
    await loadNotifications(refresh: true);
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await userRepository.markNotificationAsRead(notificationId);
      if (success) {
        final index = notifications.indexWhere((n) => n.notificationId == notificationId);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(isRead: true);
        }
        await loadUnreadCount();
      }
    } catch (_) {
      // Silently fail
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final success = await userRepository.markAllNotificationsAsRead();
      if (success) {
        for (int i = 0; i < notifications.length; i++) {
          notifications[i] = notifications[i].copyWith(isRead: true);
        }
        await loadUnreadCount();
      }
    } catch (_) {
      // Silently fail
    }
  }

  String getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
