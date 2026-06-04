import 'package:flutter/material.dart';

import '../../domain/booking_models.dart';
import '../widgets/booking_ui.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({
    required this.cart,
    required this.total,
    required this.discountCode,
    required this.onViewDetail,
    required this.onGoHome,
    super.key,
  });

  final List<CartItem> cart;
  final int total;
  final String discountCode;
  final VoidCallback onViewDetail;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    final first = cart.isEmpty ? null : cart.first;
    final deposit = (total * 0.5).round();

    return BookingShell(
      key: const ValueKey('success'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 48, 22, 24),
        children: [
          const Icon(Icons.check_circle, color: bookingPrimary, size: 96),
          const SizedBox(height: 12),
          const Text(
            'Đặt cọc thành công!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: bookingText),
          ),
          const SizedBox(height: 6),
          const Text('Mã đơn: #PB-8A9F2', textAlign: TextAlign.center, style: TextStyle(color: bookingMuted)),
          const SizedBox(height: 24),
          BookingCard(
            child: Column(
              children: [
                _ReceiptRow(icon: Icons.sports_soccer, title: first?.fieldName ?? 'Sân bóng đá', subtitle: first?.venueName ?? ''),
                const Divider(height: 26),
                _ReceiptRow(icon: Icons.schedule, title: cart.map((item) => item.time).join(', '), subtitle: first?.date ?? ''),
                const Divider(height: 26),
                BookingAmountLine(label: 'Đã thanh toán (cọc 50%)', value: money(deposit)),
                const SizedBox(height: 8),
                BookingAmountLine(label: 'Thanh toán tại sân', value: money(total - deposit), highlight: true),
                if (discountCode.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  BookingAmountLine(label: 'Mã giảm giá', value: discountCode.toUpperCase()),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          const BookingNotice(text: 'Lịch đặt đã được xác nhận. Vui lòng đến sân trước 10 phút để làm thủ tục.'),
          const SizedBox(height: 18),
          BookingPrimaryButton(label: 'Xem chi tiết đơn đặt', icon: Icons.arrow_forward, onPressed: onViewDetail),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onGoHome,
            icon: const Icon(Icons.home_outlined),
            label: const Text('Về trang chủ'),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(backgroundColor: bookingMint, foregroundColor: bookingPrimary, child: Icon(icon)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              if (subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(color: bookingMuted)),
            ],
          ),
        ),
      ],
    );
  }
}
