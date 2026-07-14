import 'package:dio/dio.dart';
import 'package:exe101/data/remote/auth/auth_api_service.dart';
import 'package:exe101/data/remote/auth/user_api_service.dart';
import 'package:exe101/data/remote/booking/booking_api_service.dart';
import 'package:exe101/data/remote/chat/chat_api_service.dart';
import 'package:exe101/data/remote/notification/notification_api_service.dart';
import 'package:exe101/data/remote/payment/payment_api_service.dart';
import 'package:exe101/data/remote/schedule/slot_schedule_api_service.dart';
import 'package:exe101/data/remote/shared/discount_api_service.dart';
import 'package:exe101/data/remote/shared/review_api_service.dart';
import 'package:exe101/data/remote/venue/field_api_service.dart';
import 'package:exe101/data/remote/venue/venue_api_service.dart';
import 'package:exe101/data/remote/venue/venue_owner_api_service.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/domain/models/chat_model.dart';
import 'package:exe101/domain/models/discount_model.dart';
import 'package:exe101/domain/models/field_model.dart';
import 'package:exe101/domain/models/field_schedule_model.dart';
import 'package:exe101/domain/models/login_response_model.dart';
import 'package:exe101/domain/models/notification_model.dart';
import 'package:exe101/domain/models/payment_model.dart';
import 'package:exe101/domain/models/review_model.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:exe101/domain/models/venue_model.dart';

part 'facade/api_service_auth_venue.dart';
part 'facade/api_service_field_booking.dart';
part 'facade/api_service_payment_chat.dart';
part 'facade/api_service_user_engagement.dart';

class ApiService {
  ApiService(this.dio);

  final Dio dio;
}

/// Compatibility facade for legacy callers. New code depends on focused
/// domain services through bindings and repositories.
class ApiServiceImpl extends ApiService {
  ApiServiceImpl(super.dio)
      : authService = AuthApiService(dio),
        userService = UserApiService(dio),
        venueService = VenueApiService(dio),
        venueOwnerService = VenueOwnerApiService(dio),
        fieldService = FieldApiService(dio),
        bookingService = BookingApiService(dio),
        slotScheduleService = SlotScheduleApiService(dio),
        paymentService = PaymentApiService(dio),
        notificationService = NotificationApiService(dio),
        chatService = ChatApiService(dio),
        discountService = DiscountApiService(dio),
        reviewService = ReviewApiService(dio);

  final AuthApiService authService;
  final UserApiService userService;
  final VenueApiService venueService;
  final VenueOwnerApiService venueOwnerService;
  final FieldApiService fieldService;
  final BookingApiService bookingService;
  final SlotScheduleApiService slotScheduleService;
  final PaymentApiService paymentService;
  final NotificationApiService notificationService;
  final ChatApiService chatService;
  final DiscountApiService discountService;
  final ReviewApiService reviewService;
}
