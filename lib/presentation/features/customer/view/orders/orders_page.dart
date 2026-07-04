import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/booking_card.dart';
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
    if (_controller.myReviews.isEmpty && !_controller.isLoadingReviews.value) {
      _controller.loadMyReviews();
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
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'Đơn đặt sân của tôi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _controller.refreshBookings,
        color: AppColors.accent,
        child: Obx(() => _buildContent()),
      ),
    );
  }

  Widget _buildContent() {
    if (_controller.isLoading.value && _controller.bookings.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 80),
          Center(child: CircularProgressIndicator(color: AppColors.accent)),
        ],
      );
    }

    if (_controller.error.value.isNotEmpty && _controller.bookings.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  _controller.error.value,
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _controller.loadBookings(refresh: true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent),
                  child: const Text('Thử lại',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_controller.bookings.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long,
                    size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'Bạn chưa có đơn đặt sân nào',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _controller.bookings.length,
      itemBuilder: (context, index) {
        return BookingCard(booking: _controller.bookings[index]);
      },
    );
  }
}
