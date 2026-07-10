import 'package:exe101/domain/models/chat_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatRoomModel role labels', () {
    final room = ChatRoomModel(
      roomId: 'room-1',
      customerId: 'customer-1',
      hostId: 'owner-1',
      createdAt: DateTime(2026, 7, 10),
      customerName: 'Customer User',
      hostName: 'Owner User',
    );

    test('identifies the current user as customer or owner', () {
      expect(room.getCurrentUserRoleLabel('customer-1'), 'Customer');
      expect(room.getCurrentUserRoleLabel('owner-1'), 'Owner');
    });

    test('identifies the chat partner as customer or owner', () {
      expect(room.getPartnerRoleLabel('customer-1'), 'Owner');
      expect(room.getPartnerRoleLabel('owner-1'), 'Customer');
    });

    test('prefers the authenticated role when room ids are reversed', () {
      final reversedRoom = ChatRoomModel(
        roomId: 'room-2',
        customerId: 'owner-1',
        hostId: 'customer-1',
        createdAt: DateTime(2026, 7, 10),
        customerName: 'Owner User',
        hostName: 'Customer User',
      );

      expect(
        reversedRoom.getCurrentUserRoleLabelForAuthRole(
          'owner-1',
          'Owner',
        ),
        'Owner',
      );
      expect(
        reversedRoom.getPartnerRoleLabelForAuthRole(
          'owner-1',
          'Owner',
        ),
        'Customer',
      );
    });

    test('uses a shared conversation label for booking and venue entry points',
        () {
      expect(room.contextLabel, 'Chat chung');
    });
  });
}
