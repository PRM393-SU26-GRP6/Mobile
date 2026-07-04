import 'package:exe101/domain/models/payment_model.dart';
import 'package:flutter/material.dart';

IconData getPaymentMethodIcon(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.sePay:
      return Icons.qr_code_2;
    case PaymentMethod.moMo:
      return Icons.account_balance_wallet;
    case PaymentMethod.vnPay:
      return Icons.payment;
    case PaymentMethod.cash:
      return Icons.payments;
  }
}

String getPaymentMethodText(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cash:
      return 'Ti뿯ẽn m뿯ẽt';
    case PaymentMethod.moMo:
      return 'MoMo';
    case PaymentMethod.vnPay:
      return 'VNPay';
    case PaymentMethod.sePay:
      return 'SePay QR';
  }
}

String getPaymentMethodDescription(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.sePay:
      return 'Qu뿯½t m뿯½ QR đ뿯ẽ thanh to뿯½n';
    case PaymentMethod.moMo:
      return 'Thanh to뿯½n qua v뿯½ MoMo';
    case PaymentMethod.vnPay:
      return 'Thanh to뿯½n qua VNPay';
    case PaymentMethod.cash:
      return 'Thanh to뿯½n tr뿯ẽc ti뿯ẽp t뿯ẽi s뿯½n';
  }
}

Color getPaymentMethodColor(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.sePay:
      return const Color(0xFF6C63FF);
    case PaymentMethod.moMo:
      return const Color(0xFFA50064);
    case PaymentMethod.vnPay:
      return const Color(0xFF0066B3);
    case PaymentMethod.cash:
      return const Color(0xFF16A34A);
  }
}

IconData getNotificationIcon(String? type) {
  switch (type?.toLowerCase()) {
    case 'booking':
      return Icons.calendar_today_outlined;
    case 'payment':
      return Icons.payment_outlined;
    case 'promotion':
      return Icons.local_offer_outlined;
    case 'system':
      return Icons.settings_outlined;
    default:
      return Icons.notifications_outlined;
  }
}

Color getNotificationColor(String? type) {
  switch (type?.toLowerCase()) {
    case 'booking':
      return const Color(0xFF0FA24A);
    case 'payment':
      return const Color(0xFF1F6C9F);
    case 'promotion':
      return const Color(0xFFE67E22);
    case 'system':
      return const Color(0xFF6B7A6D);
    default:
      return const Color(0xFF16A34A);
  }
}

String getNotificationLabel(String? type) {
  switch (type?.toLowerCase()) {
    case 'booking':
      return 'Đ뿯ẽt s뿯½n';
    case 'payment':
      return 'Thanh to뿯½n';
    case 'promotion':
      return 'Khuy뿯ẽn m뿯½i';
    case 'system':
      return 'H뿯ẽ th뿯ẽng';
    default:
      return 'Th뿯½ng b뿯½o';
  }
}

class BookingStatusStyle {
  final Color color;
  final Color bgColor;
  final String label;

  const BookingStatusStyle({
    required this.color,
    required this.bgColor,
    required this.label,
  });
}

BookingStatusStyle getBookingStatusStyle(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return const BookingStatusStyle(
        color: Color(0xFFD97706),
        bgColor: Color(0xFFFFF3CD),
        label: 'Ch뿯ẽ duy뿯ẽt',
      );
    case 'accepted':
    case 'confirmed':
      return const BookingStatusStyle(
        color: Color(0xFF16A34A),
        bgColor: Color(0xFFDCFCE7),
        label: 'Đ뿯½ x뿯½c nh뿯ẽn',
      );
    case 'deposited':
      return const BookingStatusStyle(
        color: Color(0xFF0D6EFD),
        bgColor: Color(0xFFCCE5FF),
        label: 'Đ뿯½ đ뿯ẽt c뿯ẽc',
      );
    case 'completed':
      return const BookingStatusStyle(
        color: Color(0xFF2563EB),
        bgColor: Color(0xFFDBEAFE),
        label: 'Ho뿯½n th뿯½nh',
      );
    case 'cancelled':
    case 'rejected':
      final label = status.toLowerCase() == 'cancelled' ? 'Đã hủy' : 'Từ chối';
      return BookingStatusStyle(
        color: const Color(0xFFDC2626),
        bgColor: const Color(0xFFFEE2E2),
        label: label,
      );
    default:
      return BookingStatusStyle(
        color: Colors.grey,
        bgColor: Colors.grey.shade200,
        label: status.isEmpty ? 'Kh뿯½ng r뿯½' : status,
      );
  }
}
