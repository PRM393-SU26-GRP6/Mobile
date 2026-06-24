import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/auth/controller/auth_controller.dart';
import 'package:exe101/presentation/features/owner/controller/booking_management_controller.dart';
import 'package:exe101/presentation/features/owner/controller/owner_home_controller.dart';
import 'package:exe101/presentation/features/owner/view/widgets/empty_fields_widget.dart';
import 'package:exe101/presentation/features/owner/view/widgets/field_list_item.dart';
import 'package:exe101/presentation/features/owner/view/widgets/venue_selector.dart';
import 'package:exe101/presentation/features/owner/view/widgets/venue_stats_card.dart';
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshAll(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
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
                      child: VenueStatsCard(venue: controller.selectedVenue.value!),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
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
                                      AppColors.buttonGradientEnd
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
                      ),
                    ),
                    if (controller.isLoadingFields.value)
                      const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
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
                                onEdit: () => _showEditFieldDialog(field.fieldName ?? 'Sân'),
                              );
                            },
                            childCount: controller.fields.length,
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 24),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildNavButton(
                    icon: Icons.stadium,
                    label: 'Quản lý sân',
                    isSelected: true,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNavButton(
                    icon: Icons.calendar_today,
                    label: 'Duyệt đặt sân',
                    isSelected: false,
                    badge: Get.find<BookingManagementController>().pendingCount,
                    onTap: () => Get.toNamed(AppPages.bookingManagement),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    int badge = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                if (badge > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badge > 9 ? '9+' : '$badge',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
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
            Text(
              'Tạo sân đầu tiên để bắt đầu quản lý',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => _showCreateVenueDialog(Get.context!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.buttonGradientStart, AppColors.buttonGradientEnd],
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

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              Get.find<AuthController>().logout();
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
