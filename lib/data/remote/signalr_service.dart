import 'dart:async';
import 'package:exe101/core/config/env.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:get/get.dart';

class SignalRService extends GetxService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  HubConnection? _chatHubConnection;
  HubConnection? _notificationHubConnection;

  // StreamControllers to broadcast events
  final _chatMessageController = StreamController<Map<String, dynamic>>.broadcast();
  final _notificationCountController = StreamController<int>.broadcast();
  final _notificationCreatedController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onChatMessageReceived => _chatMessageController.stream;
  Stream<int> get onNotificationUnreadCountChanged => _notificationCountController.stream;
  Stream<Map<String, dynamic>> get onNotificationCreated => _notificationCreatedController.stream;

  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> initChatConnection() async {
    if (_chatHubConnection?.state == HubConnectionState.Connected) return;

    final token = await _getToken();
    if (token == null) return;

    final chatHubUrl = '${Env.baseUrl}/hubs/chat';

    _chatHubConnection = HubConnectionBuilder()
        .withUrl(
          chatHubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
          ),
        )
        .withAutomaticReconnect()
        .build();

    _chatHubConnection?.onclose(({error}) {
      print('ChatHub connection closed: $error');
    });

    _chatHubConnection?.on('chat.messageCreated', _handleChatMessage);

    try {
      await _chatHubConnection?.start();
      print('ChatHub connected successfully');
    } catch (e) {
      print('ChatHub connection error: $e');
    }
  }

  Future<void> initNotificationConnection() async {
    if (_notificationHubConnection?.state == HubConnectionState.Connected) return;

    final token = await _getToken();
    if (token == null) return;

    final notifHubUrl = '${Env.baseUrl}/hubs/notifications';

    _notificationHubConnection = HubConnectionBuilder()
        .withUrl(
          notifHubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
          ),
        )
        .withAutomaticReconnect()
        .build();

    _notificationHubConnection?.onclose(({error}) {
      print('NotificationHub connection closed: $error');
    });

    _notificationHubConnection?.on('notification.unreadCountChanged', _handleUnreadCount);
    _notificationHubConnection?.on('notification.created', _handleNotificationCreated);

    try {
      await _notificationHubConnection?.start();
      print('NotificationHub connected successfully');
    } catch (e) {
      print('NotificationHub connection error: $e');
    }
  }

  Future<void> joinChatRoom(String roomId) async {
    if (_chatHubConnection?.state == HubConnectionState.Connected) {
      try {
        await _chatHubConnection?.invoke('JoinRoom', args: [roomId]);
      } catch (e) {
        print('Error joining chat room: $e');
      }
    }
  }

  Future<void> leaveChatRoom(String roomId) async {
    if (_chatHubConnection?.state == HubConnectionState.Connected) {
      try {
        await _chatHubConnection?.invoke('LeaveRoom', args: [roomId]);
      } catch (e) {
        print('Error leaving chat room: $e');
      }
    }
  }

  void _handleChatMessage(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      final msgData = args[0] as Map<String, dynamic>;
      _chatMessageController.add(msgData);
    }
  }

  void _handleUnreadCount(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      // The payload might be just an int or a map containing count
      final data = args[0];
      if (data is int) {
        _notificationCountController.add(data);
      } else if (data is Map<String, dynamic>) {
        final count = data['count'] ?? data['unreadCount'] ?? 0;
        _notificationCountController.add(count as int);
      }
    }
  }

  void _handleNotificationCreated(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      final msgData = args[0] as Map<String, dynamic>;
      _notificationCreatedController.add(msgData);
    }
  }

  Future<void> stopConnections() async {
    if (_chatHubConnection?.state == HubConnectionState.Connected) {
      await _chatHubConnection?.stop();
    }
    if (_notificationHubConnection?.state == HubConnectionState.Connected) {
      await _notificationHubConnection?.stop();
    }
  }

  @override
  void onClose() {
    stopConnections();
    _chatMessageController.close();
    _notificationCountController.close();
    _notificationCreatedController.close();
    super.onClose();
  }
}
