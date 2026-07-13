import 'package:exe101/presentation/features/owner/view/home/widgets/owner_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders notifications tab with unread badge', (tester) async {
    var notificationTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: OwnerNavBar(
            selectedIndex: 0,
            pendingCount: 0,
            notificationCount: 12,
            onFieldsTap: () {},
            onBookingsTap: () {},
            onMessagesTap: () {},
            onRevenueTap: () {},
            onNotificationsTap: () {
              notificationTapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Thông báo'), findsOneWidget);
    expect(find.text('9+'), findsOneWidget);

    await tester.tap(find.text('Thông báo'));
    expect(notificationTapped, isTrue);
  });
}
