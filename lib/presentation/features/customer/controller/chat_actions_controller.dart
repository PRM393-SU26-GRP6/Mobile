import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/domain/models/chat_model.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:exe101/domain/repositories/chat_repository.dart';
import 'package:exe101/data/remote/signalr_service.dart';
import 'package:get/get.dart';

class ChatActionsController extends GetxController {
  final ChatRepository chatRepository;
  final SignalRService signalRService;

  ChatActionsController({
    required this.chatRepository,
    required this.signalRService,
  });

  Stream<Map<String, dynamic>> get messagesReceived {
    return signalRService.onChatMessageReceived;
  }

  Future<void> connectRoom(String roomId) async {
    await signalRService.initChatConnection();
    await signalRService.joinChatRoom(roomId);
  }

  Future<void> leaveRoom(String roomId) {
    return signalRService.leaveChatRoom(roomId);
  }

  Future<String?> getCurrentUserId() => chatRepository.getCurrentUserId();

  Future<String?> getCurrentUserRole() => chatRepository.getCurrentUserRole();

  Future<List<ChatRoomModel>> getRooms() => chatRepository.getRooms();

  Future<List<MessageModel>> getMessages({
    required String roomId,
    int pageNumber = 1,
    int pageSize = 50,
  }) {
    return chatRepository.getMessages(
      roomId: roomId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  Future<void> sendMessage({
    required String roomId,
    required String messageText,
  }) async {
    await chatRepository.sendMessage(
      roomId: roomId,
      messageText: messageText,
    );
  }

  Future<ChatRoomModel?> startWithVenue(VenueModel venue) async {
    var resolvedVenue = venue;
    if (resolvedVenue.ownerId == null || resolvedVenue.ownerId!.isEmpty) {
      resolvedVenue = await chatRepository.getVenue(venue.id) ?? venue;
    }

    final ownerId = resolvedVenue.ownerId;
    final customerId = await chatRepository.getCurrentUserId();
    if (ownerId == null || ownerId.isEmpty || customerId == null) return null;

    return chatRepository.createRoom(
      CreateChatRoomRequest(
        customerId: customerId,
        ownerId: ownerId,
        venueId: resolvedVenue.id,
      ),
    );
  }

  Future<ChatRoomModel?> startWithCustomer(BookingDto booking) async {
    final ownerId = await chatRepository.getCurrentUserId();
    if (booking.userId.isEmpty || ownerId == null || ownerId.isEmpty) {
      return null;
    }

    return chatRepository.createRoom(
      CreateChatRoomRequest(
        customerId: booking.userId,
        ownerId: ownerId,
        bookingId: booking.id.isEmpty ? null : booking.id,
      ),
    );
  }
}
