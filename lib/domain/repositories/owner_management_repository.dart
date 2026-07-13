import 'package:exe101/data/remote/schedule/owner_resource_api_service.dart';
import 'package:exe101/data/remote/owner/owner_stats_api_service.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/domain/models/revenue_model.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:exe101/domain/models/venue_image_model.dart';
import 'package:image_picker/image_picker.dart';

/// Repository layer wrapping focused owner-side remote services.
///
/// Controllers should talk to this repository instead of the API services
/// directly so the data source can later be swapped or mocked.
class OwnerManagementRepository {
  final OwnerStatsApiService statsService;
  final OwnerResourceApiService resourceService;

  OwnerManagementRepository({
    required this.statsService,
    required this.resourceService,
  });

  Future<Map<String, dynamic>> getOwnerStats() => statsService.getOwnerStats();

  Future<RevenueResponse> getOwnerRevenue({
    DateTime? from,
    DateTime? to,
    String groupBy = 'day',
  }) =>
      statsService.getOwnerRevenue(from: from, to: to, groupBy: groupBy);

  Future<BookingDto?> getOwnerBookingById(String bookingId) =>
      resourceService.getOwnerBookingById(bookingId);

  Future<TimeSlotDto> updateOwnerSlot({
    required String slotId,
    double? price,
    String? status,
  }) =>
      resourceService.updateOwnerSlot(
        slotId,
        price: price,
        status: status,
      );

  Future<void> deleteOwnerSlot(String slotId) =>
      resourceService.deleteOwnerSlot(slotId);

  /// Lấy danh sách ảnh venue.
  ///
  /// Bước 1: Gọi `GET /api/v1/Venues/{id}/images` (public endpoint, owner token ok)
  /// để lấy ảnh thực tế từ BE.
  ///
  /// Bước 2: Nếu endpoint không trả được (401/404/null), fallback sang
  /// `existingUrls` (venue.images từ model truyền vào — có thể rỗng).
  ///
  /// Sau khi upload, BE chỉ trả "OK" nên không refresh được ngay.
  Future<List<VenueImageDto>> getVenueImages({
    required String venueId,
    List<String>? existingUrls,
  }) async {
    // Bước 1: thử lấy từ BE
    try {
      final apiImages = await resourceService.getVenueImages(venueId);
      if (apiImages.isNotEmpty) return apiImages;
    } catch (_) {
      // ignore - fallback
    }

    // Bước 2: fallback sang venue.images đã có
    if (existingUrls == null || existingUrls.isEmpty) return const [];
    return existingUrls
        .where((u) => u.trim().isNotEmpty)
        .map<VenueImageDto>(
          (url) => VenueImageDto(
            imageUrl: url,
            venueId: venueId,
            imageId: _extractIdFromUrl(url),
          ),
        )
        .toList();
  }

  String? _extractIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segs = uri.pathSegments;
      if (segs.length >= 2 && segs[segs.length - 2] == 'images') {
        return segs.last;
      }
    } catch (_) {
      // ignore
    }
    return null;
  }

  Future<List<String>?> uploadVenueImages({
    required String venueId,
    required List<XFile> files,
  }) =>
      resourceService.uploadVenueImages(
        venueId: venueId,
        files: files,
      );

  Future<void> deleteVenueImage({
    required String venueId,
    required String imageId,
  }) =>
      resourceService.deleteVenueImage(
        venueId: venueId,
        imageId: imageId,
      );
}
