import 'package:exe101/presentation/features/auth/controller/session_state_resetter.dart';
import 'package:exe101/presentation/features/customer/controller/customer_home_controller.dart';
import 'package:exe101/presentation/features/owner/controller/slot_selection_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() => Get.testMode = true);

  tearDown(Get.reset);

  test('clears controllers that contain data from the previous account',
      () async {
    Get.put(CustomerHomeController());
    Get.put(SlotSelectionController());

    expect(Get.isRegistered<CustomerHomeController>(), isTrue);
    expect(Get.isRegistered<SlotSelectionController>(), isTrue);

    await SessionStateResetter.clearUserBoundState();

    expect(Get.isRegistered<CustomerHomeController>(), isFalse);
    expect(Get.isRegistered<SlotSelectionController>(), isFalse);
  });
}
