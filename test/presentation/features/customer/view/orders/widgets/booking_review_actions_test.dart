import 'package:exe101/presentation/features/customer/view/orders/widgets/booking_review_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('labels edit and delete actions as feedback actions',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BookingReviewActions(
            onEditTap: () {},
            onDeleteTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Sửa feedback'), findsOneWidget);
    expect(find.text('Xóa feedback'), findsOneWidget);
    expect(find.text('Sửa'), findsNothing);
    expect(find.text('Xóa'), findsNothing);
  });
}
