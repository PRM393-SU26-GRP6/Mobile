import 'package:dio/dio.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/presentation/features/owner/controller/slot_management_controller.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/slot_management_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() => Get.testMode = true);

  tearDown(Get.reset);

  testWidgets('only shows create and slots list tabs', (tester) async {
    Get.put(SlotManagementController(apiService: ApiServiceImpl(Dio())));

    await tester.pumpWidget(const GetMaterialApp(home: SlotManagementPage()));

    expect(find.text('Tạo slots'), findsOneWidget);
    expect(find.text('Danh sách'), findsOneWidget);
    expect(find.text('Lịch sân'), findsNothing);
  });
}
