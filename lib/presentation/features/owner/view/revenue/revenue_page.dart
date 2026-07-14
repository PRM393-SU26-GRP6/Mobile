import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/revenue_controller.dart';
import 'package:exe101/presentation/features/owner/view/revenue/widgets/revenue_chart_card.dart';
import 'package:exe101/presentation/features/owner/view/revenue/widgets/revenue_detail_list.dart';
import 'package:exe101/presentation/features/owner/view/revenue/widgets/revenue_error_state.dart';
import 'package:exe101/presentation/features/owner/view/revenue/widgets/revenue_range_selector.dart';
import 'package:exe101/presentation/features/owner/view/revenue/widgets/revenue_summary_cards.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RevenuePage extends StatelessWidget {
  final bool embedded;

  const RevenuePage({
    super.key,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RevenueController>();

    final content = _RevenueContent(controller: controller);

    if (embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Doanh thu',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            icon: const Icon(Icons.refresh),
            onPressed: controller.refresh,
          ),
        ],
      ),
      body: content,
    );
  }
}

class _RevenueContent extends StatelessWidget {
  final RevenueController controller;

  const _RevenueContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: AppColors.primary,
      child: Obx(() {
        if (controller.isLoading.value &&
            controller.revenue.value.groups.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.revenue.value.groups.isEmpty) {
          return RevenueErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.refresh,
          );
        }

        final revenue = controller.revenue.value;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            RevenueRangeSelector(controller: controller),
            const SizedBox(height: 16),
            const Text(
              'Tổng quan toàn thời gian',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            RevenueSummaryCards(revenue: revenue),
            const SizedBox(height: 16),
            RevenueChartCard(groups: revenue.groups),
            const SizedBox(height: 16),
            RevenueDetailList(groups: revenue.groups),
          ],
        );
      }),
    );
  }
}
