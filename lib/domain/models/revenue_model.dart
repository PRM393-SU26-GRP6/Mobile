/// Tổng quan từ `/owner/stats` kết hợp với các nhóm từ `/owner/revenue`.
class RevenueResponse {
  final double totalRevenue;
  final double depositRevenue;
  final double finalPaymentRevenue;
  final DateTime? from;
  final DateTime? to;
  final String groupBy;
  final List<RevenuePoint> groups;

  const RevenueResponse({
    required this.totalRevenue,
    required this.depositRevenue,
    required this.finalPaymentRevenue,
    required this.from,
    required this.to,
    required this.groupBy,
    required this.groups,
  });

  factory RevenueResponse.empty() => const RevenueResponse(
        totalRevenue: 0,
        depositRevenue: 0,
        finalPaymentRevenue: 0,
        from: null,
        to: null,
        groupBy: 'day',
        groups: <RevenuePoint>[],
      );
}

/// Một điểm doanh thu theo nhóm ngày hoặc tháng.
class RevenuePoint {
  final String? label;
  final DateTime? date;
  final double revenue;
  final double deposit;
  final double finalPayment;
  final int paymentCount;

  const RevenuePoint({
    this.label,
    this.date,
    required this.revenue,
    required this.deposit,
    required this.finalPayment,
    required this.paymentCount,
  });

  factory RevenuePoint.fromJson(Map<String, dynamic> json) {
    final rawDate =
        json['date'] ?? json['period'] ?? json['label'] ?? json['key'];
    DateTime? parsed;
    if (rawDate is String && rawDate.isNotEmpty) {
      try {
        parsed = DateTime.parse(rawDate);
      } catch (_) {
        parsed = null;
      }
    }

    return RevenuePoint(
      label: json['label']?.toString() ??
          json['key']?.toString() ??
          rawDate?.toString(),
      date: parsed,
      revenue: (json['revenue'] as num?)?.toDouble() ??
          (json['amount'] as num?)?.toDouble() ??
          (json['total'] as num?)?.toDouble() ??
          0,
      deposit: (json['deposit'] as num?)?.toDouble() ??
          (json['depositRevenue'] as num?)?.toDouble() ??
          0,
      finalPayment: (json['finalPayment'] as num?)?.toDouble() ??
          (json['finalPaymentRevenue'] as num?)?.toDouble() ??
          0,
      paymentCount: (json['payments'] as num?)?.toInt() ??
          (json['bookingCount'] as num?)?.toInt() ??
          (json['count'] as num?)?.toInt() ??
          0,
    );
  }

  static int compareChronologically(RevenuePoint a, RevenuePoint b) {
    final aDate = a.date;
    final bDate = b.date;
    if (aDate != null && bDate != null) return aDate.compareTo(bDate);
    return (a.label ?? '').compareTo(b.label ?? '');
  }
}
