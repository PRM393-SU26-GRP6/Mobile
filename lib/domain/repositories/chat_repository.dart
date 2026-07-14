import 'package:exe101/data/remote/auth/auth_api_service.dart';
import 'package:exe101/data/remote/chat/chat_api_service.dart';
import 'package:exe101/data/remote/venue/venue_api_service.dart';
import 'package:exe101/domain/models/chat_model.dart';
import 'package:exe101/domain/models/venue_model.dart';

class ChatRepository {
  final AuthApiService authApiService;
  final ChatApiService chatApiService;
  final VenueApiService venueApiService;

  ChatRepository({
    required this.authApiService,
    required this.chatApiService,
    required this.venueApiService,
  });

  Future<String?> getCurrentUserId() => authApiService.getUserId();

  Future<String?> getCurrentUserRole() => authApiService.getUserRole();

  Future<VenueModel?> getVenue(String venueId) {
    return venueApiService.getVenueById(venueId);
  }

  Future<List<ChatRoomModel>> getRooms({
    int pageNumber = 1,
    int pageSize = 20,
  }) {
    return chatApiService.getChatRooms(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  Future<ChatRoomModel> createRoom(CreateChatRoomRequest request) {
    return chatApiService.createChatRoom(request);
  }

  Future<List<MessageModel>> getMessages({
    required String roomId,
    int pageNumber = 1,
    int pageSize = 50,
  }) {
    return chatApiService.getChatMessages(
      roomId: roomId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  Future<MessageModel> sendMessage({
    required String roomId,
    required String messageText,
  }) {
    return chatApiService.sendMessage(
      roomId: roomId,
      messageText: messageText,
    );
  }

  Future<void> markAsRead(String roomId) {
    return chatApiService.markChatAsRead(roomId);
  }
}
