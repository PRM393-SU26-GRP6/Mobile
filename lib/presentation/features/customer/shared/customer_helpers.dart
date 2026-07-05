import 'package:intl/intl.dart';

String formatDateVN(DateTime dt) {
  return DateFormat('dd/MM/yyyy').format(dt);
}

String formatDateTimeVN(DateTime dt) {
  return DateFormat('dd/MM/yyyy HH:mm').format(dt);
}

String formatTimeHM(DateTime dt) {
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

String timeAgoVN(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inDays > 0) return '${diff.inDays} ngày trước';
  if (diff.inHours > 0) return '${diff.inHours} giờ trước';
  if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
  return 'Vừa xong';
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String formatPriceVN(double price) {
  final formatter = NumberFormat('#,###', 'vi_VN');
  return '${formatter.format(price)}đ';
}

String getInitials(String? name) {
  if (name == null || name.trim().isEmpty) return '?';
  final cleaned = name.trim();
  final parts = cleaned.split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return cleaned.substring(0, cleaned.length >= 2 ? 2 : 1).toUpperCase();
}
