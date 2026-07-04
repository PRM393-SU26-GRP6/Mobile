import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/booking_management_controller.dart';
import 'package:exe101/presentation/features/owner/controller/owner_home_controller.dart';
import 'package:exe101/presentation/features/owner/view/home/widgets/empty_fields_widget.dart';
import 'package:exe101/presentation/features/owner/view/home/widgets/field_list_item.dart';
import 'package:exe101/presentation/features/owner/view/home/widgets/owner_nav_bar.dart';
import 'package:exe101/presentation/features/owner/view/home/widgets/venue_selector.dart';
import 'package:exe101/presentation/features/owner/view/home/widgets/venue_stats_card.dart';
import 'package:exe101/presentation/features/owner/view/shared/owner_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OwnerHomePage extends StatelessWidget {
  const OwnerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OwnerHomeController>();

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Quản Lý Sân',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshAll(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => showOwnerLogoutDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshAll(),
        color: AppColors.primary,
        child: Column(
          children: [
            Obx(() => VenueSelector(
                  venues: controller.venues,
                  selectedVenue: controller.selectedVenue.value,
                  onVenueSelected: controller.selectVenue,
                  onAddVenue: () => _showCreateVenueDialog(context),
                )),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingVenues.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (controller.selectedVenue.value == null) {
                  return _buildNoVenueState();
                }
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: VenueStatsCard(
                        venue: controller.selectedVenue.value!,
                      ),
                    ),
                    SliverToBoxAdapter(child: _buildFieldsHeader(controller)),
                    if (controller.isLoadingFields.value)
                      const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else if (controller.fields.isEmpty)
                      SliverFillRemaining(
                        child: EmptyFieldsWidget(
                          onAddField: () => _navigateToCreateField(
                            controller.selectedVenue.value!.id,
                            controller.selectedVenue.value!.venueName ?? 'Sân',
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final field = controller.fields[index];
                              return FieldListItem(
                                field: field,
                                onTap: () => _showFieldDetails(
                                  field.fieldName ?? 'Sân',
                                  field.id ?? '',
                                ),
                                onEdit: () => _showEditFieldDialog(
                                  field.fieldName ?? 'Sân',
                                ),
                              );
                            },
                            childCount: controller.fields.length,
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() => OwnerNavBar(
            pendingCount: Get.find<BookingManagementController>().pendingCount,
            onFieldsTap: () {},
            onBookingsTap: () => Get.toNamed(AppPages.bookingManagement),
          )),
    );
  }

  Widget _buildFieldsHeader(OwnerHomeController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Danh Sách Sân Con',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: () => _navigateToCreateField(
              controller.selectedVenue.value!.id,
              controller.selectedVenue.value!.venueName ?? 'Sân',
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.buttonGradientStart,
                    AppColors.buttonGradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Thêm',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoVenueState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stadium_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Chưa có sân',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tạo sân đầu tiên để bắt đầu quản lý',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => _showCreateVenueDialog(Get.context!),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.buttonGradientStart,
                      AppColors.buttonGradientEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Tạo Sân',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateField(String venueId, String venueName) {
    Get.toNamed(
      AppPages.addField,
      arguments: {'venueId': venueId, 'venueName': venueName},
    )?.then((_) {
      Get.find<OwnerHomeController>().refreshAll();
    });
  }

  void _showCreateVenueDialog(BuildContext context) {
    Get.toNamed(AppPages.venueCreation)?.then((_) {
      Get.find<OwnerHomeController>().refreshAll();
    });
  }

  void _showFieldDetails(String fieldName, String fieldId) {
    Get.toNamed(AppPages.fieldDetail, arguments: {'fieldId': fieldId});
  }

  void _showEditFieldDialog(String fieldName) {
    Get.snackbar('Sửa', 'Chỉnh sửa: $fieldName');
  }
}
