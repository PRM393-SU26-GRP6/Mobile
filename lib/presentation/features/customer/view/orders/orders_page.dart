import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late final BookingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<BookingController>();
    if (_controller.bookings.isEmpty) {
      _controller.loadBookings(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + topPad),
        child: Container(
          padding: EdgeInsets.only(top: topPad),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Text(
                'Đơn hàng',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Obx(() => _buildContent()),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_controller.isLoading.value && _controller.bookings.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_controller.error.value.isNotEmpty && _controller.bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              _controller.error.value,
              style: TextStyle(color: Colors.grey.shade400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _controller.refreshBookings(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Thử lại',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_controller.bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: AppColors.accent),
            SizedBox(height: 16),
            Text(
              'Chưa có đơn hàng nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Các đơn đặt sân sẽ hiển thị tại đây',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () => _controller.refreshBookings(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 100) {
            _controller.loadBookings();
          }
          return false;
        },
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _controller.bookings.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == _controller.bookings.length) {
              if (_controller.hasMore.value) {
                return Obx(() => _controller.isLoadingMore.value
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink());
              }
              return const SizedBox.shrink();
            }

            final booking = _controller.bookings[index];
            return _BookingCard(booking: booking);
          },
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingDto booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _venueName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _StatusBadge(status: booking.bookingStatus ?? ''),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _slotSummary,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _dateRange,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _priceText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  if (_showDepositButton)
                    GestureDetector(
                      onTap: _onDepositTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D6EFD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Thanh toán cọc',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (_showDepositButton) const SizedBox(width: 8),
                  Text(
                    _timeAgo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _venueName {
    if (booking.items != null && booking.items!.isNotEmpty) {
      return booking.items!.first.venueName ?? 'Sân bóng';
    }
    return 'Sân bóng';
  }

  String get _slotSummary {
    final itemCount = booking.items?.length ?? 0;
    if (itemCount == 0) return 'Chưa có thông tin slot';
    final first = booking.items!.first;
    final fieldName = first.fieldName ?? 'Sân';
    return '$fieldName · $itemCount khung giờ';
  }

  String get _dateRange {
    if (booking.items == null || booking.items!.isEmpty) {
      return '';
    }
    final dates = booking.items!
        .map((i) =>
            '${i.startTime.day}/${i.startTime.month}/${i.startTime.year}')
        .toSet()
        .toList()
      ..sort();
    if (dates.length == 1) return 'Ngày: ${dates.first}';
    return 'Ngày: ${dates.first} → ${dates.last}';
  }

  String get _priceText {
    if (booking.discountAmount > 0) {
      return '${booking.totalPrice.toStringAsFixed(0)}đ (-${booking.discountAmount.toStringAsFixed(0)}đ)';
    }
    return '${booking.totalPrice.toStringAsFixed(0)}đ';
  }

  bool get _showDepositButton =>
      booking.bookingStatus?.toLowerCase() == 'accepted';

  void _onDepositTap() {
    // TODO: xử lý thanh toán cọc
  }

  String get _timeAgo {
    final diff = DateTime.now().difference(booking.createdAt);
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bgColor, label) = _resolve();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  (Color, Color, String) _resolve() {
    switch (status.toLowerCase()) {
      case 'pending':
        return (const Color(0xFFD97706), const Color(0xFFFFF3CD), 'Chờ duyệt');
      case 'accepted':
        return (
          const Color(0xFF16A34A),
          const Color(0xFFDCFCE7),
          'Đã xác nhận'
        );
      case 'deposited':
        return (const Color(0xFF0D6EFD), const Color(0xFFCCE5FF), 'Đã đặt cọc');
      case 'confirmed':
        return (
          const Color(0xFF16A34A),
          const Color(0xFFDCFCE7),
          'Đã xác nhận'
        );
      case 'completed':
        return (const Color(0xFF2563EB), const Color(0xFFDBEAFE), 'Hoàn thành');
      case 'cancelled':
        return (const Color(0xFFDC2626), const Color(0xFFFEE2E2), 'Đã hủy');
      case 'rejected':
        return (const Color(0xFFDC2626), const Color(0xFFFEE2E2), 'Từ chối');
      default:
        return (
          Colors.grey,
          Colors.grey.shade200,
          status.isEmpty ? 'Không rõ' : status
        );
    }
  }
}
