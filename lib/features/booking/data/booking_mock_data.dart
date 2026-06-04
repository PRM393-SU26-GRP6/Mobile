import '../domain/booking_models.dart';

const bookingVenues = [
  Venue(
    id: 'v1',
    name: 'Sân Bóng Đá Thống Nhất',
    address: '123 Nguyễn Văn Linh, Q.7, TP.HCM',
    rating: 4.8,
    reviewCount: 312,
    priceFrom: 150000,
    priceTo: 280000,
    types: ['5', '7'],
    amenities: ['Bãi đỗ xe', 'Nhà vệ sinh', 'Căn tin', 'Cho thuê giày'],
    openHours: '06:00 - 22:00',
    fields: [
      FieldInfo(id: 'f1', name: 'Sân 1 (5 người)', type: '5', price: 150000),
      FieldInfo(id: 'f2', name: 'Sân 2 (5 người)', type: '5', price: 150000),
      FieldInfo(id: 'f3', name: 'Sân 3 (7 người)', type: '7', price: 220000),
    ],
  ),
  Venue(
    id: 'v2',
    name: 'Phức Hợp Thể Thao Gia Định',
    address: '45 Hoàng Minh Giám, Gò Vấp, TP.HCM',
    rating: 4.6,
    reviewCount: 198,
    priceFrom: 180000,
    priceTo: 350000,
    types: ['5', '7', '11'],
    amenities: ['Bãi đỗ xe', 'Nhà vệ sinh', 'Phòng thay đồ', 'Camera'],
    openHours: '05:30 - 23:00',
    fields: [
      FieldInfo(id: 'f4', name: 'Sân A (7 người)', type: '7', price: 250000),
      FieldInfo(id: 'f5', name: 'Sân B (11 người)', type: '11', price: 350000),
    ],
  ),
  Venue(
    id: 'v3',
    name: 'Sân Cỏ Nhân Tạo Phú Nhuận',
    address: '78 Phan Đình Phùng, Phú Nhuận, TP.HCM',
    rating: 4.4,
    reviewCount: 87,
    priceFrom: 120000,
    priceTo: 200000,
    types: ['5'],
    amenities: ['Nhà vệ sinh', 'Căn tin'],
    openHours: '07:00 - 21:00',
    fields: [
      FieldInfo(id: 'f6', name: 'Sân Mini 1', type: '5', price: 120000),
      FieldInfo(id: 'f7', name: 'Sân Mini 2', type: '5', price: 140000),
    ],
  ),
  Venue(
    id: 'v4',
    name: 'Trung Tâm Thể Thao Tân Bình',
    address: '200 Cộng Hòa, Tân Bình, TP.HCM',
    rating: 4.7,
    reviewCount: 445,
    priceFrom: 200000,
    priceTo: 400000,
    types: ['7', '11'],
    amenities: [
      'Bãi đỗ xe',
      'Nhà vệ sinh',
      'Phòng thay đồ',
      'Căn tin',
      'Camera',
      'Đèn chiếu',
    ],
    openHours: '06:00 - 23:30',
    fields: [
      FieldInfo(
        id: 'f8',
        name: 'Sân Chính (11 người)',
        type: '11',
        price: 400000,
      ),
      FieldInfo(id: 'f9', name: 'Sân Phụ (7 người)', type: '7', price: 250000),
    ],
  ),
];

const bookingSlots = [
  SlotInfo(id: 's1', time: '06:00 - 07:00', status: SlotStatus.booked),
  SlotInfo(id: 's2', time: '07:00 - 08:00', status: SlotStatus.booked),
  SlotInfo(id: 's3', time: '08:00 - 09:00', status: SlotStatus.available),
  SlotInfo(id: 's4', time: '09:00 - 10:00', status: SlotStatus.available),
  SlotInfo(id: 's5', time: '10:00 - 11:00', status: SlotStatus.locked),
  SlotInfo(id: 's6', time: '11:00 - 12:00', status: SlotStatus.available),
  SlotInfo(id: 's7', time: '13:00 - 14:00', status: SlotStatus.available),
  SlotInfo(id: 's8', time: '14:00 - 15:00', status: SlotStatus.available),
  SlotInfo(id: 's9', time: '15:00 - 16:00', status: SlotStatus.booked),
  SlotInfo(id: 's10', time: '16:00 - 17:00', status: SlotStatus.booked),
  SlotInfo(id: 's11', time: '17:00 - 18:00', status: SlotStatus.available),
  SlotInfo(id: 's12', time: '18:00 - 19:00', status: SlotStatus.available),
  SlotInfo(id: 's13', time: '19:00 - 20:00', status: SlotStatus.locked),
  SlotInfo(id: 's14', time: '20:00 - 21:00', status: SlotStatus.available),
  SlotInfo(id: 's15', time: '21:00 - 22:00', status: SlotStatus.available),
];

const bookingConversations = [
  Conversation(
    name: 'Chủ sân Thống Nhất',
    lastMessage: 'Sân số 3 còn trống từ 18:00 đến 20:00.',
    time: '2 phút trước',
    unread: 1,
    online: true,
  ),
  Conversation(
    name: 'Sân Phức Hợp Gia Định',
    lastMessage: 'Cảm ơn bạn. Hẹn gặp lại vào tuần sau nhé!',
    time: 'Hôm qua',
    unread: 0,
    online: false,
  ),
  Conversation(
    name: 'Nhóm Kèo Chiều T5',
    lastMessage: 'Minh: Tuần này mình bận rồi, anh em cứ đánh nhé.',
    time: 'T3',
    unread: 0,
    online: false,
    isGroup: true,
  ),
  Conversation(
    name: 'Sân Phú Nhuận Mini',
    lastMessage: 'Slot 16:00 vẫn còn trống, bạn có muốn đặt không?',
    time: 'T2',
    unread: 2,
    online: true,
  ),
];

const initialChatMessages = [
  ChatMessage(
    sender: 'customer',
    text: 'Chào bạn, mình muốn hỏi về lịch đặt sân tối nay lúc 19:00.',
    time: '09:15',
    read: true,
  ),
  ChatMessage(
    sender: 'owner',
    text:
        'Chào bạn, sân số 3 lúc 20:00 vẫn còn trống. Mình đã dời lịch cho bạn rồi nhé.',
    time: '09:20',
    read: true,
  ),
  ChatMessage(
    sender: 'owner',
    text: 'Bạn vui lòng thanh toán phần còn lại tại quầy khi đến sân nhé.',
    time: '09:21',
    read: true,
  ),
  ChatMessage(
    sender: 'customer',
    text: 'Cảm ơn bạn. Mình sẽ chuyển khoản luôn.',
    time: '09:25',
    read: true,
  ),
];
