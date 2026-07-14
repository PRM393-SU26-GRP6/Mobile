import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:flutter/material.dart';

abstract final class BookingDisplay {
  static String fieldName(BookingDto booking) {
    final firstItem =
        booking.items?.isNotEmpty == true ? booking.items!.first : null;
    return firstItem?.fieldName ?? 'Sân';
  }

  static String dateLabel(DateTime value) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(value.year, value.month, value.day);
    if (date == today) return 'Hôm nay';
    if (date == today.add(const Duration(days: 1))) return 'Ngày mai';
    return '${value.day}/${value.month}/${value.year}';
  }

  static String time(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String compactMoney(double value) => '${value.toStringAsFixed(0)}K';

  static String statusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Chờ duyệt';
      case 'accepted':
      case 'confirmed':
        return 'Đã xác nhận';
      case 'deposited':
        return 'Đã đặt cọc';
      case 'cancelled':
        return 'Đã hủy';
      case 'completed':
        return 'Hoàn thành';
      case 'rejected':
        return 'Từ chối';
      default:
        return status ?? 'Không rõ';
    }
  }

  static Color statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
      case 'confirmed':
      case 'deposited':
        return AppColors.primary;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }
}
