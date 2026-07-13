import 'package:exe101/presentation/features/customer/controller/customer_home_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('openCart selects the cart tab', () {
    final controller = CustomerHomeController();

    controller.openCart();

    expect(controller.currentIndex.value, CustomerHomeController.cartTabIndex);
  });
}
