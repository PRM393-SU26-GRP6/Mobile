import 'package:dio/dio.dart';
import 'package:exe101/core/config/env.dart';
import 'package:exe101/data/remote/_base_api_service.dart';
import 'package:exe101/domain/models/notification_model.dart';

/// Notification endpoints:
/// - GET /api/v1/notifications
/// - GET /api/v1/notifications/unread-count
/// - PUT /api/v1/notifications/{id}/read
/// - PUT /api/v1/notifications/read-all
class NotificationApiService extends BaseApiService {
  NotificationApiService(super.dio);

  Future<List<NotificationModel>> getNotifications({
    bool unreadOnly = false,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final headers = await authHeaders();
    final params = <String, dynamic>{
      'unreadOnly': unreadOnly,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    final response = await dio.get<dynamic>(
      '${Env.baseUrl}/api/v1/notifications',
      queryParameters: params,
      options: Options(headers: headers),
    );

    if (response.data == null) return [];
    final list = BaseApiService.extractList(response.data);
    return list
        .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadNotificationCount() async {
    final headers = await authHeaders();
    final response = await dio.get<dynamic>(
      '${Env.baseUrl}/api/v1/notifications/unread-count',
      options: Options(headers: headers),
    );

    if (response.data == null) return 0;
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('unreadCount')) {
        return data['unreadCount'] as int? ?? 0;
      }
      if (data.containsKey('count')) {
        return data['count'] as int? ?? 0;
      }
    }
    if (response.data is int) return response.data as int;
    return 0;
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    final headers = await authHeaders();
    try {
      final response = await dio.put<Map<String, dynamic>>(
        '${Env.baseUrl}/api/v1/notifications/$notificationId/read',
        options: Options(headers: headers),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markAllNotificationsAsRead() async {
    final headers = await authHeaders();
    try {
      final response = await dio.put<Map<String, dynamic>>(
        '${Env.baseUrl}/api/v1/notifications/read-all',
        options: Options(headers: headers),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
