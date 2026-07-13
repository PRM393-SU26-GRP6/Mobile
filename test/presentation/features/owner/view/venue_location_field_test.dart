import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/presentation/features/owner/view/shared/venue_location_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('runs the picker binding and returns selected coordinates',
      (tester) async {
    VenueLocationSelection? selected;

    await tester.pumpWidget(
      GetMaterialApp(
        getPages: [
          GetPage(
            name: AppPages.venueLocationPicker,
            binding: BindingsBuilder(
              () => Get.lazyPut<_PickerDependency>(_PickerDependency.new),
            ),
            page: () {
              Get.find<_PickerDependency>();
              final args = Get.arguments as Map;
              return Scaffold(
                body: Column(
                  children: [
                    Text(
                      '${args['latitude']},${args['longitude']},${args['address']}',
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: {
                        'latitude': 10.123456,
                        'longitude': 106.654321,
                      }),
                      child: const Text('Confirm location'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        home: Scaffold(
          body: VenueLocationField(
            latitude: 10.1,
            longitude: 106.6,
            onTap: () async {
              selected = await pickVenueLocation(
                Get.context!,
                latitude: 10.1,
                longitude: 106.6,
                address: '123 Nguyen Trai',
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Vị trí trên bản đồ'));
    await tester.pumpAndSettle();

    expect(find.text('10.1,106.6,123 Nguyen Trai'), findsOneWidget);
    expect(Get.isRegistered<_PickerDependency>(), isTrue);

    await tester.tap(find.text('Confirm location'));
    await tester.pumpAndSettle();

    expect(selected?.latitude, 10.123456);
    expect(selected?.longitude, 106.654321);
  });
}

class _PickerDependency {}
