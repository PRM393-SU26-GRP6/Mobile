import 'package:flutter/material.dart';

import '../widgets/booking_ui.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({required this.onBack, super.key});

  final VoidCallback onBack;

  static const _items = [
    ('✅', 'Lịch đặt được chấp nhận', 'Sân số 4, Thống Nhất đã được chủ sân xác nhận.', '2 phút trước', true),
    ('💳', 'Thanh toán thành công', 'Giao dịch đặt cọc 190.000đ đã hoàn tất.', '1 giờ trước', false),
    ('💬', 'Tin nhắn mới từ Chủ sân', 'Sân đã sẵn sàng, hẹn gặp bạn lúc 18:00 nhé!', '3 giờ trước', false),
    ('🎁', 'Khuyến mãi cuối tuần', 'Giảm 20% khi đặt sân vào khung giờ sáng cuối tuần.', '1 ngày trước', false),
    ('⚽', 'Nhắc nhở trận đấu', 'Bạn có lịch đặt sân Gia Định vào lúc 18:00 hôm nay.', '2 ngày trước', false),
  ];

  @override
  Widget build(BuildContext context) {
    return BookingShell(
      key: const ValueKey('notifications'),
      child: Column(
        children: [
          BookingTopBar(title: 'Thông báo', onBack: onBack, actionLabel: 'Đọc tất cả'),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _items[index];
                return _NotificationTile(
                  icon: item.$1,
                  title: item.$2,
                  body: item.$3,
                  time: item.$4,
                  unread: item.$5,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.unread,
  });

  final String icon;
  final String title;
  final String body;
  final String time;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    return BookingCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: bookingMint, child: Text(icon)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900))),
                    Text(time, style: const TextStyle(color: bookingMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(color: bookingMuted)),
              ],
            ),
          ),
          if (unread)
            const Padding(
              padding: EdgeInsets.only(left: 8, top: 4),
              child: CircleAvatar(radius: 4, backgroundColor: bookingPrimaryLight),
            ),
        ],
      ),
    );
  }
}
