import 'package:flutter/material.dart';

import '../../domain/booking_models.dart';
import '../widgets/booking_ui.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({
    required this.info,
    required this.onBack,
    required this.onConfirm,
    super.key,
  });

  final PaymentInfo info;
  final VoidCallback onBack;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final first = info.cart.first;
    final deposit = (info.total * 0.5).round();

    return BookingShell(
      key: const ValueKey('payment'),
      child: Column(
        children: [
          BookingTopBar(title: 'Thanh toán', onBack: onBack),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
              children: [
                BookingCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Thông tin sân', style: TextStyle(color: bookingPrimary, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      _ReceiptRow(icon: Icons.sports_soccer, title: first.fieldName, subtitle: first.venueName),
                      const Divider(height: 26),
                      _ReceiptRow(icon: Icons.calendar_month_outlined, title: '${info.cart.length} slot · ${first.date}', subtitle: first.time),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                BookingCard(
                  child: Column(
                    children: [
                      BookingAmountLine(label: 'Tạm tính (${info.cart.length} slot)', value: money(info.subtotal)),
                      if (info.discount > 0) ...[
                        const SizedBox(height: 8),
                        BookingAmountLine(label: 'Giảm giá', value: '-${money(info.discount)}'),
                      ],
                      const Divider(height: 24),
                      BookingAmountLine(label: 'Tổng thanh toán', value: money(info.total), highlight: true),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const BookingCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BookingSectionTitle(title: 'Phương thức thanh toán'),
                      _PaymentMethod(icon: Icons.account_balance_wallet_outlined, title: 'Ví PitchPay', selected: true, subtitle: 'Thanh toán cọc 50% ngay'),
                      _PaymentMethod(icon: Icons.qr_code_2, title: 'Chuyển khoản QR', selected: false, subtitle: 'Xác nhận tự động trong vài phút'),
                      _PaymentMethod(icon: Icons.payments_outlined, title: 'Tiền mặt tại sân', selected: false, subtitle: 'Chỉ áp dụng phần còn lại'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                BookingNotice(text: 'Bạn thanh toán trước ${money(deposit)}. Phần còn lại trả tại sân sau khi đá xong.'),
              ],
            ),
          ),
          BookingBottomAction(label: 'Xác nhận đặt cọc', icon: Icons.verified_outlined, onPressed: onConfirm),
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
              Text(subtitle, style: const TextStyle(color: bookingMuted)),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentMethod extends StatelessWidget {
  const _PaymentMethod({required this.icon, required this.title, required this.subtitle, required this.selected});

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: selected ? bookingPrimary : bookingMint,
        foregroundColor: selected ? Colors.white : bookingPrimary,
        child: Icon(icon),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? bookingPrimary : bookingMuted),
    );
  }
}
