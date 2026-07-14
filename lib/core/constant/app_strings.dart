abstract final class AppStrings {
  static const appName = 'PitchBook';

  static const common = _CommonStrings();
  static const auth = _AuthStrings();
  static const navigation = _NavigationStrings();
  static const venue = _VenueStrings();
  static const booking = _BookingStrings();
  static const payment = _PaymentStrings();
  static const review = _ReviewStrings();
}

class _CommonStrings {
  const _CommonStrings();

  final String close = 'Đóng';
  final String cancel = 'Hủy';
  final String save = 'Lưu';
  final String retry = 'Thử lại';
  final String error = 'Lỗi';
  final String success = 'Thành công';
  final String refresh = 'Làm mới';
  final String logout = 'Đăng xuất';
}

class _AuthStrings {
  const _AuthStrings();

  final String login = 'Đăng nhập';
  final String register = 'Đăng ký';
  final String loginWelcome = 'Chào mừng bạn quay lại PitchBook.';
  final String quickBooking = 'Đặt sân bóng nhanh chóng';
  final String noAccount = 'Chưa có tài khoản? Đăng ký';
}

class _NavigationStrings {
  const _NavigationStrings();

  final String home = 'Trang chủ';
  final String map = 'Bản đồ';
  final String bookings = 'Đơn đặt';
  final String messages = 'Tin nhắn';
  final String notifications = 'Thông báo';
  final String revenue = 'Doanh thu';
}

class _VenueStrings {
  const _VenueStrings();

  final String venue = 'Cụm sân';
  final String venues = 'Các cụm sân';
  final String field = 'Mặt sân';
  final String fields = 'Các mặt sân';
  final String timeSlot = 'Khung giờ';
  final String timeSlots = 'Các khung giờ';
  final String manageVenues = 'Quản lý cụm sân';
}

class _BookingStrings {
  const _BookingStrings();

  final String details = 'Chi tiết đơn đặt sân';
  final String approve = 'Duyệt đặt sân';
  final String empty = 'Chưa có đơn đặt sân';
}

class _PaymentStrings {
  const _PaymentStrings();

  final String payment = 'Thanh toán';
  final String deposit = 'Thanh toán cọc';
  final String remaining = 'Thanh toán phần còn lại';
  final String noTransactions = 'Chưa có giao dịch thanh toán.';
}

class _ReviewStrings {
  const _ReviewStrings();

  final String review = 'Đánh giá';
  final String reviews = 'Các đánh giá';
  final String notFound = 'Không tìm thấy đánh giá';
  final String deleteFailed = 'Không thể xóa đánh giá. Vui lòng thử lại.';
}
