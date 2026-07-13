import 'package:dio/dio.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/presentation/features/owner/controller/venue_edit_controller.dart';
import 'package:exe101/presentation/features/owner/view/venue_edit/widgets/venue_edit_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('reacts to saving state without an invalid Obx scope',
      (tester) async {
    final controller = VenueEditController(apiService: ApiServiceImpl(Dio()));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VenueEditForm(controller: controller, onSave: () async {}),
        ),
      ),
    );
    expect(tester.takeException(), isNull);

    controller.isSaving.value = true;
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    controller.onClose();
  });
}
