import 'package:exe101/domain/models/field_model.dart';
import 'package:flutter/material.dart';

String formatDateVN(DateTime dt) =>
    '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

String formatDateTimeVN(DateTime dt) =>
    '${formatDateVN(dt)} ${formatTimeHM(dt)}';

String formatTimeHM(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

String formatPriceVN(double price) {
  if (price >= 1000) {
    final intPart = (price / 1000).toStringAsFixed(0);
    return '$intPart.000d';
  }
  return '${price.toStringAsFixed(0)}d';
}

String fieldTypeLabel(String? type) =>
    FieldModel.fieldTypeLabels[type] ?? type ?? 'Sân';

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
