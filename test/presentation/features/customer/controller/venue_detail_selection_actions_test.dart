import 'package:dio/dio.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/data/remote/shared/review_api_service.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:exe101/domain/repositories/review_repository.dart';
import 'package:exe101/domain/repositories/slot_repository.dart';
import 'package:exe101/presentation/features/customer/controller/venue_detail_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads selectable slots from the date-specific available endpoint',
      () async {
    final repository = _FakeSlotRepository(
      availableByDate: {
        _dateAfter(0): [_slot('available-result', _dateAfter(0))],
      },
    );
    final controller = _controller(repository);

    await controller.loadSlots('field-1');

    expect(repository.bookableRequests, [('field-1', _dateAfter(0))]);
    expect(controller.availableDates, isNotEmpty);
    expect(controller.timeSlots.map((slot) => slot.slotId), [
      'available-result',
    ]);
    expect(controller.timeSlots.any((slot) => slot.isBooked), isFalse);

    controller.onClose();
  });

  test('does not lock an available response without a persisted slot id',
      () async {
    final repository = _FakeSlotRepository(availableByDate: const {});
    final controller = _controller(repository);
    final virtualSlot = _slot('', _dateAfter(0));
    controller.selectedField.value = FootballFieldDto(id: 'field-1');
    controller.timeSlots.add(virtualSlot);

    await controller.toggleSlot(virtualSlot.selectionKey);

    expect(controller.selectedSlotIds, isEmpty);
    expect(controller.timeSlots.single.slotId, isEmpty);
    expect(repository.lockRequests, isEmpty);

    controller.selectedSlotIds.clear();
    controller.onClose();
  });
}

VenueDetailController _controller(SlotRepository slotRepository) {
  final dio = Dio();
  return VenueDetailController(
    apiService: ApiService(dio),
    slotRepository: slotRepository,
    reviewRepository: ReviewRepository(
      reviewApiService: ReviewApiService(dio),
    ),
  );
}

String _dateAfter(int days) {
  final date = DateTime.now().add(Duration(days: days));
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

TimeSlotDto _slot(
  String id,
  String date, {
  String status = 'Available',
}) {
  return TimeSlotDto(
    slotId: id,
    fieldId: 'field-1',
    startTime: '09:00:00',
    endTime: '10:00:00',
    selectedDate: date,
    price: 100000,
    slotStatus: status,
  );
}

class _FakeSlotRepository implements SlotRepository {
  _FakeSlotRepository({
    required this.availableByDate,
  });

  final Map<String, List<TimeSlotDto>> availableByDate;
  final List<(String, String)> availableRequests = [];
  final List<(String, String)> bookableRequests = [];
  final List<String> lockRequests = [];

  @override
  Future<List<TimeSlotDto>> getSlotsByField(String fieldId) async {
    return [];
  }

  @override
  Future<List<TimeSlotDto>> getBookableSlots({
    required String fieldId,
    required String date,
  }) async {
    bookableRequests.add((fieldId, date));
    return availableByDate[date] ?? [];
  }

  @override
  Future<List<TimeSlotDto>> getAvailableSlots({
    required String fieldId,
    required String date,
  }) async {
    availableRequests.add((fieldId, date));
    return availableByDate[date] ?? [];
  }

  @override
  Future<SlotLockResult> lockSlot({
    required String slotId,
  }) async {
    lockRequests.add(slotId);
    return const SlotLockResult(slotId: 'locked-slot');
  }

  @override
  Future<bool> unlockSlot(String slotId) async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
