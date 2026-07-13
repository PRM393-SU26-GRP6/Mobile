import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/auth/controller/auth_controller.dart';
import 'package:exe101/presentation/features/customer/controller/venue_controller.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/home_venue_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final venueController = Get.find<VenueController>();
    final authController = Get.find<AuthController>();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(authController),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    _buildSearchBar(venueController),
                    _buildFilterChips(venueController),
                    Expanded(child: _buildVenueList(venueController)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AuthController authController) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('TP. Hồ Chí Minh',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    SizedBox(height: 4),
                    Text('TÌM SÂN BÓNG',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppPages.userProfile),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_outline, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    onChanged: Get.find<VenueController>().search,
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.black45),
                      hintText: 'Tìm tên sân, địa chỉ...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12)),
                child: IconButton(
                  icon: const Icon(Icons.exit_to_app, color: Colors.white),
                  onPressed: () => _showLogoutDialog(authController),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(VenueController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          onChanged: controller.search,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm cụm sân...',
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(AuthController authController) async {
    final shouldLogout = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      authController.logout();
    } catch (_) {
      Get.offAllNamed('/login');
    }
  }

  Widget _buildFilterChips(VenueController controller) {
    return Obx(() {
      final amenities = controller.allAmenities;
      if (amenities.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: amenities.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final amenity = amenities[index];
            final amenityId = amenity.id ?? '';
            final isSelected =
                controller.selectedAmenityIds.contains(amenityId);

            return GestureDetector(
              onTap: () {
                if (amenityId.isNotEmpty) {
                  controller.toggleAmenityFilter(amenityId);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? null
                      : Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (amenity.icon != null && amenity.icon!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Image.network(
                          amenity.icon!,
                          width: 16,
                          height: 16,
                          color:
                              isSelected ? Colors.white : Colors.grey.shade700,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    Text(
                      amenity.amenityName ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildVenueList(VenueController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.venues.isEmpty) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.accent));
      }

      if (controller.error.value.isNotEmpty && controller.venues.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                controller.error.value,
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.loadVenues,
                style:
                    ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                child: const Text('Thử lại',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }

      if (controller.venues.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_soccer, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Chưa có cụm sân nào',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshVenues,
        color: AppColors.accent,
        child: Obx(() {
          final itemCount =
              controller.venues.length + (controller.hasMore.value ? 1 : 0);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index < controller.venues.length) {
                return HomeVenueCard(venue: controller.venues[index]);
              }

              if (controller.isLoadingMore.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: ElevatedButton(
                    onPressed: controller.loadMore,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent),
                    child: const Text('Xem thêm',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              );
            },
          );
        }),
      );
    });
  }
}
