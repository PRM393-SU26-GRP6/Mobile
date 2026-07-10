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

    expect(find.text('Sua feedback'), findsOneWidget);
    expect(find.text('Xoa feedback'), findsOneWidget);
    expect(find.text('Sua'), findsNothing);
    expect(find.text('Xoa'), findsNothing);
  });
}
