import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_deletion_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows progress for one deleting time slot', (tester) async {
    await _pumpOverlay(tester, slotCount: 1);

    expect(find.text('Đang xóa khung giờ...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byKey(const Key('slot-deletion-barrier')), findsOneWidget);
  });

  testWidgets('shows the selected count while deleting multiple time slots',
      (tester) async {
    await _pumpOverlay(tester, slotCount: 3);

    expect(find.text('Đang xóa 3 khung giờ...'), findsOneWidget);
  });
}

Future<void> _pumpOverlay(
  WidgetTester tester, {
  required int slotCount,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            const SizedBox.expand(),
            SlotDeletionOverlay(slotCount: slotCount),
          ],
        ),
      ),
    ),
  );
}
