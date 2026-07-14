import 'package:exe101/domain/models/revenue_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RevenuePoint', () {
    test('parses the owner revenue response from production', () {
      final point = RevenuePoint.fromJson({
        'key': '2026-07-14',
        'revenue': 350000,
        'payments': 2,
      });

      expect(point.label, '2026-07-14');
      expect(point.date, DateTime(2026, 7, 14));
      expect(point.revenue, 350000);
      expect(point.paymentCount, 2);
    });

    test('sorts revenue points chronologically', () {
      final newest = RevenuePoint.fromJson({
        'key': '2026-07-14',
        'revenue': 200000,
        'payments': 1,
      });
      final oldest = RevenuePoint.fromJson({
        'key': '2026-07-01',
        'revenue': 150000,
        'payments': 1,
      });
      final points = [newest, oldest]
        ..sort(RevenuePoint.compareChronologically);

      expect(points, [oldest, newest]);
    });
  });
}
