import 'package:exe101/presentation/features/auth/binding/auth_binding.dart';
import 'package:exe101/presentation/features/auth/view/login_page.dart';
import 'package:exe101/presentation/features/auth/view/otp_verification_page.dart';
import 'package:exe101/presentation/features/auth/view/register_page.dart';
import 'package:exe101/presentation/features/auth/view/role_selection_page.dart';
import 'package:exe101/presentation/features/customer/binding/customer_binding.dart';
import 'package:exe101/presentation/features/customer/binding/notification_binding.dart';
import 'package:exe101/presentation/features/customer/view/customer_home_page.dart';
import 'package:exe101/presentation/features/customer/view/home/venue_detail_page.dart';
import 'package:exe101/presentation/features/customer/view/notifications/notifications_page.dart';
import 'package:exe101/presentation/features/customer/view/orders/payment_history_page.dart';
import 'package:exe101/presentation/features/customer/view/orders/payment_qr_page.dart';
import 'package:exe101/presentation/features/customer/view/orders/select_payment_method_page.dart';
import 'package:exe101/presentation/features/customer/view/profile/user_profile_page.dart';
import 'package:exe101/presentation/features/owner/binding/owner_binding.dart';
import 'package:exe101/presentation/features/owner/view/booking/booking_management_page.dart';
import 'package:exe101/presentation/features/owner/view/field/add_field_page.dart';
import 'package:exe101/presentation/features/owner/view/field/field_detail_page.dart';
import 'package:exe101/presentation/features/owner/view/home/owner_home_page.dart';
import 'package:exe101/presentation/features/owner/view/revenue/revenue_page.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/slot_management_page.dart';
import 'package:exe101/presentation/features/owner/view/venue_creation_page.dart';
import 'package:exe101/presentation/features/owner/view/venue_images/venue_images_page.dart';
import 'package:exe101/presentation/features/splash/binding/splash_binding.dart';
import 'package:exe101/presentation/features/splash/view/splash_view.dart';
import 'package:get/get.dart';

class AppPages {
  // Route names
  static const String splash = '/splash';
  static const String login = '/login';
  static const String roleSelection = '/role-selection';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String customerHome = '/customer-home';
  static const String ownerHome = '/owner-home';
  static const String venueDetail = '/venue-detail';
  static const String venueCreation = '/owner/venue-creation';
  static const String addField = '/owner/add-field';
  static const String bookingManagement = '/owner/bookings';
  static const String fieldDetail = '/owner/field-detail';
  static const String slotManagement = '/owner/slot-management';
  static const String paymentQR = '/payment-qr';
  static const String selectPaymentMethod = '/select-payment-method';
  static const String userProfile = '/user-profile';
  static const String notifications = '/notifications';
  static const String revenue = '/owner/revenue';
  static const String venueImages = '/owner/venue-images';
  static const String paymentHistory = '/payment-history';

  // GetX pages configuration
  static final List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: roleSelection,
      page: () => const RoleSelectionPage(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: otpVerification,
      page: () => const OtpVerificationPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: customerHome,
      page: () => const CustomerHomePage(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: venueDetail,
      page: () => const VenueDetailPage(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: ownerHome,
      page: () => const OwnerHomePage(),
      binding: OwnerBinding(),
    ),
    GetPage(
      name: venueCreation,
      page: () => const VenueCreationPage(),
      binding: OwnerBinding(),
    ),
    GetPage(
      name: addField,
      page: () => const AddFieldPage(),
      binding: OwnerBinding(),
    ),
    GetPage(
      name: bookingManagement,
      page: () => const BookingManagementPage(),
      binding: OwnerBinding(),
    ),
    GetPage(
      name: fieldDetail,
      page: () => const FieldDetailPage(),
      binding: OwnerBinding(),
    ),
    GetPage(
      name: slotManagement,
      page: () => const SlotManagementPage(),
      binding: OwnerBinding(),
    ),
    GetPage(
      name: paymentQR,
      page: () => const PaymentQRPage(),
    ),
    GetPage(
      name: selectPaymentMethod,
      page: () => const SelectPaymentMethodPage(),
    ),
    GetPage(
      name: userProfile,
      page: () => const UserProfilePage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: notifications,
      page: () => const NotificationsPage(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: revenue,
      page: () => const RevenuePage(),
      binding: OwnerBinding(),
    ),
    GetPage(
      name: venueImages,
      page: () => const VenueImagesPage(),
      binding: OwnerBinding(),
    ),
    GetPage(
      name: paymentHistory,
      page: () => const PaymentHistoryPage(),
      binding: CustomerBinding(),
    ),
  ];

  // Prevent instantiation
  AppPages._();
}
