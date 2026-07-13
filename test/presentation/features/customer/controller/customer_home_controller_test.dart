import 'package:exe101/presentation/features/customer/controller/customer_home_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('changePage selects the requested customer tab', () {
    final controller = CustomerHomeController();

    controller.changePage(3);

    expect(controller.currentIndex.value, 3);
  });
}
