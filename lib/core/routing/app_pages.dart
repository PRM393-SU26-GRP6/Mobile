import 'package:exe101/presentation/features/auth/binding/auth_binding.dart';
import 'package:exe101/presentation/features/auth/view/login_page.dart';
import 'package:exe101/presentation/features/auth/view/otp_verification_page.dart';
import 'package:exe101/presentation/features/auth/view/register_page.dart';
import 'package:exe101/presentation/features/auth/view/role_selection_page.dart';
import 'package:exe101/presentation/features/customer/binding/customer_binding.dart';
import 'package:exe101/presentation/features/customer/view/customer_home_page.dart';
import 'package:exe101/presentation/features/customer/view/home/venue_detail_page.dart';
import 'package:exe101/presentation/features/owner/binding/owner_binding.dart';
import 'package:exe101/presentation/features/owner/view/add_field_page.dart';
import 'package:exe101/presentation/features/owner/view/booking_management_page.dart';
import 'package:exe101/presentation/features/owner/view/create_field_page.dart';
import 'package:exe101/presentation/features/owner/view/owner_home_page.dart';
import 'package:exe101/presentation/features/owner/view/venue_creation_page.dart';
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
  static const String createField = '/owner/create-field';
  static const String venueCreation = '/owner/venue-creation';
  static const String addField = '/owner/add-field';
  static const String bookingManagement = '/owner/bookings';

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
      name: createField,
      page: () => const CreateFieldPage(),
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
  ];

  // Prevent instantiation
  AppPages._();
}
