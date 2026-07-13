import 'package:get/get.dart';

class CustomerHomeController extends GetxController {
  static const int cartTabIndex = 2;

  final currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  void openCart() {
    currentIndex.value = cartTabIndex;
  }
}
