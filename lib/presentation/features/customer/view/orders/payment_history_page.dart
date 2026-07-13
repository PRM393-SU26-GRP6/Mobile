import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/payment_history_controller.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/payment_history_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentHistoryPage extends StatelessWidget {
  const PaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PaymentHistoryController>();

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Lịch sử thanh toán',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshPayments,
        color: AppColors.accent,
        child: Obx(() {
          if (controller.isLoading.value && controller.payments.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          if (controller.error.value.isNotEmpty &&
              controller.payments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(controller.error.value,
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.refreshPayments,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent),
                    child: const Text('Thử lại',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          if (controller.payments.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount:
                controller.payments.length + (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.payments.length) {
                if (!controller.isLoadingMore.value) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    controller.loadPayments();
                  });
                }
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),
                );
              }

              final payment = controller.payments[index];
              return PaymentHistoryCard(payment: payment);
            },
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chưa có giao dịch nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lịch sử thanh toán của bạn sẽ hiển thị ở đây',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
