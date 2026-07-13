import 'package:dio/dio.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/presentation/features/owner/controller/venue_edit_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('requires both venue name and address before saving', () {
    final controller = VenueEditController(apiService: ApiServiceImpl(Dio()));

    expect(controller.validateForm(), isNotNull);

    controller.nameController.text = 'Pitchbook Arena';
    expect(controller.validateForm(), isNotNull);

    controller.addressController.text = 'District 1, Ho Chi Minh City';
    expect(controller.validateForm(), isNull);

    controller.onClose();
  });
}
