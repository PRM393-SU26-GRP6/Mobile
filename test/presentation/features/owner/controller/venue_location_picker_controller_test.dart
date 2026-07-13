import 'package:exe101/domain/models/geocoding_result.dart';
import 'package:exe101/domain/repositories/geocoding_repository.dart';
import 'package:exe101/presentation/features/owner/controller/venue_location_picker_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('moves the selection to the address search result', () async {
    final controller = VenueLocationPickerController(
      geocodingRepository: _FakeGeocodingRepository(
        const GeocodingResult(
          latitude: 10.85,
          longitude: 106.77,
          displayName: 'Linh Xuân, Thủ Đức, Hồ Chí Minh',
        ),
      ),
    );
    controller.initialize({'address': 'Linh Xuan, Thu Duc'});

    await controller.searchInitialAddress();

    expect(controller.selectedLocation.value.latitude, 10.85);
    expect(controller.selectedLocation.value.longitude, 106.77);
    expect(controller.searchSucceeded.value, isTrue);
    controller.onClose();
  });

  test('keeps the current location when the address cannot be found', () async {
    final controller = VenueLocationPickerController(
      geocodingRepository: _FakeGeocodingRepository(null),
    );
    controller.initialize({
      'address': 'not found',
      'latitude': 10.1,
      'longitude': 106.2,
    });

    await controller.searchInitialAddress();

    expect(controller.selectedLocation.value.latitude, 10.1);
    expect(controller.selectedLocation.value.longitude, 106.2);
    expect(controller.searchSucceeded.value, isFalse);
    expect(controller.searchMessage.value, contains('Không tìm thấy'));
    controller.onClose();
  });

  test('labels a simplified address result as approximate', () async {
    final controller = VenueLocationPickerController(
      geocodingRepository: _FakeGeocodingRepository(
        const GeocodingResult(
          latitude: 10.88,
          longitude: 106.77,
          displayName: 'Linh Xuân, Thủ Đức',
          isApproximate: true,
        ),
      ),
    );
    controller.initialize({'address': 'Hẻm 25, Linh Xuân, Thủ Đức, TP.HCM'});

    await controller.searchInitialAddress();

    expect(controller.searchMessage.value, contains('Kết quả gần đúng'));
    controller.onClose();
  });
}

class _FakeGeocodingRepository implements GeocodingRepository {
  _FakeGeocodingRepository(this.result);

  final GeocodingResult? result;

  @override
  Future<GeocodingResult?> findAddress(String address) async => result;
}
