import 'package:exe101/domain/models/booking_model.dart';

extension BookingCardPresentation on BookingDto {
  String get venueName => items?.firstOrNull?.venueName ?? 'Sân bóng';

  String get slotSummary {
    final itemCount = items?.length ?? 0;
    if (itemCount == 0) return 'Chưa có thông tin khung giờ';
    return '${items!.first.fieldName ?? 'Sân'} · $itemCount khung giờ';
  }

  String get dateRange {
    if (items == null || items!.isEmpty) return '';
    final dates = items!
        .map((item) =>
            '${item.startTime.day}/${item.startTime.month}/${item.startTime.year}')
        .toSet()
        .toList()
      ..sort();
    return dates.length == 1
        ? 'Ngày: ${dates.first}'
        : 'Ngày: ${dates.first} → ${dates.last}';
  }

  String get priceText => discountAmount > 0
      ? '${totalPrice.toStringAsFixed(0)}đ '
          '(-${discountAmount.toStringAsFixed(0)}đ)'
      : '${totalPrice.toStringAsFixed(0)}đ';

  bool get isCompleted => bookingStatus?.toLowerCase() == 'completed';
}
