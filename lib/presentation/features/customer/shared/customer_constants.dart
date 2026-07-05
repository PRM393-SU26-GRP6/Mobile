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
      return 'Tiền mặt';
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
      return 'Quét mã QR để thanh toán';
    case PaymentMethod.moMo:
      return 'Thanh toán qua ví MoMo';
    case PaymentMethod.vnPay:
      return 'Thanh toán qua VNPay';
    case PaymentMethod.cash:
      return 'Thanh toán trực tiếp tại sân';
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
      return 'Đặt sân';
    case 'payment':
      return 'Thanh toán';
    case 'promotion':
      return 'Khuyến mãi';
    case 'system':
      return 'Hệ thống';
    default:
      return 'Thông báo';
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
        label: 'Chờ duyệt',
      );
    case 'accepted':
    case 'confirmed':
      return const BookingStatusStyle(
        color: Color(0xFF16A34A),
        bgColor: Color(0xFFDCFCE7),
        label: 'Đã xác nhận',
      );
    case 'deposited':
      return const BookingStatusStyle(
        color: Color(0xFF0D6EFD),
        bgColor: Color(0xFFCCE5FF),
        label: 'Đã đặt cọc',
      );
    case 'completed':
      return const BookingStatusStyle(
        color: Color(0xFF2563EB),
        bgColor: Color(0xFFDBEAFE),
        label: 'Hoàn thành',
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
        label: status.isEmpty ? 'Không rõ' : status,
      );
  }
}
