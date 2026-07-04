import 'package:exe101/domain/models/field_model.dart';
import 'package:flutter/material.dart';

/// Format DateTime thành dd/MM/yyyy.
String formatDateVN(DateTime dt) =>
    '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

/// Format phần thời gian dd/MM/yyyy HH:mm.
String formatDateTimeVN(DateTime dt) =>
    '${formatDateVN(dt)} ${formatTimeHM(dt)}';

/// Format thành HH:mm.
String formatTimeHM(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

/// Format giá slot kiểu "100.000đ" (chia cho 1000 nếu >= 1000).
String formatPriceVN(double price) {
  if (price >= 1000) {
    final intPart = (price / 1000).toStringAsFixed(0);
    return '$intPart.000đ';
  }
  return '${price.toStringAsFixed(0)}đ';
}

/// Trả về nhãn hiển thị của loại sân.
String fieldTypeLabel(String? type) =>
    FieldModel.fieldTypeLabels[type] ?? type ?? 'Sân';

/// Tính giá nhỏ nhất trong các loại giá của field.
double fieldMinPrice(FieldModel field) {
  final prices = <double>[];
  if (field.pricePerHour != null && field.pricePerHour! > 0) {
    prices.add(field.pricePerHour!);
  }
  if (field.priceMorning != null && field.priceMorning! > 0) {
    prices.add(field.priceMorning!);
  }
  if (field.priceAfternoon != null && field.priceAfternoon! > 0) {
    prices.add(field.priceAfternoon!);
  }
  if (field.priceEvening != null && field.priceEvening! > 0) {
    prices.add(field.priceEvening!);
  }
  return prices.isEmpty ? 0 : prices.reduce((a, b) => a < b ? a : b);
}

/// Màu theo trạng thái booking.
Color bookingStatusColor(String? status) {
  switch (status?.toLowerCase()) {
    case 'pending':
      return Colors.orange;
    case 'accepted':
    case 'confirmed':
      return Colors.blue;
    case 'deposited':
      return Colors.teal;
    case 'completed':
      return Colors.green;
    case 'cancelled':
    case 'rejected':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
