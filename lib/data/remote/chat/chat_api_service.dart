import 'package:dio/dio.dart';
import 'package:exe101/core/config/env.dart';
import 'package:exe101/data/remote/_base_api_service.dart';
import 'package:exe101/domain/models/chat_model.dart';

/// Chat endpoints (rooms + messages):
/// - GET  /api/v1/chats/rooms
/// - POST /api/v1/chats/rooms
/// - GET  /api/v1/chats/rooms/{roomId}/messages
/// - POST /api/v1/chats/rooms/{roomId}/messages
/// - PUT  /api/v1/chats/rooms/{roomId}/read
class ChatApiService extends BaseApiService {
  ChatApiService(super.dio);

  Future<List<ChatRoomModel>> getChatRooms({
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final headers = await authHeaders();
    final params = <String, dynamic>{
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    final response = await dio.get<dynamic>(
      '${Env.baseUrl}/api/v1/chats/rooms',
      queryParameters: params,
      options: Options(headers: headers),
    );

    if (response.data == null) return [];
    final list = BaseApiService.extractList(response.data);
    return list
        .map((json) =>
            ChatRoomModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<ChatRoomModel> createChatRoom(CreateChatRoomRequest request) async {
    final headers = await authJsonHeaders();
    final response = await dio.post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/chats/rooms',
      data: request.toJson(),
      options: Options(headers: headers),
    );

    final data = response.data?['data'] ?? response.data ?? {};
    return ChatRoomModel.fromJson(data is Map<String, dynamic> ? data : {});
  }

  Future<List<MessageModel>> getChatMessages({
    required String roomId,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    final headers = await authHeaders();
    final params = <String, dynamic>{
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    final response = await dio.get<dynamic>(
      '${Env.baseUrl}/api/v1/chats/rooms/$roomId/messages',
      queryParameters: params,
      options: Options(headers: headers),
    );

    if (response.data == null) return [];
    final list = BaseApiService.extractList(response.data);
    return list
        .map((json) =>
            MessageModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<MessageModel> sendMessage({
    required String roomId,
    required String messageText,
  }) async {
    final headers = await authJsonHeaders();
    final response = await dio.post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/chats/rooms/$roomId/messages',
      data: {'messageText': messageText},
      options: Options(headers: headers),
    );

    final data = response.data?['data'] ?? response.data ?? {};
    return MessageModel.fromJson(data is Map<String, dynamic> ? data : {});
  }

  Future<void> markChatAsRead(String roomId) async {
    final headers = await authHeaders();
    await dio.put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/chats/rooms/$roomId/read',
      options: Options(headers: headers),
    );
  }
}
