import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:exe101/presentation/features/owner/controller/owner_home_controller.dart';
import 'package:exe101/presentation/features/owner/view/home/widgets/empty_fields_widget.dart';
import 'package:exe101/presentation/features/owner/view/home/widgets/field_list_item.dart';
import 'package:exe101/presentation/features/owner/view/home/widgets/venue_selector.dart';
import 'package:exe101/presentation/features/owner/view/home/widgets/venue_stats_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OwnerFieldsTab extends StatelessWidget {
  final OwnerHomeController controller;
  final VoidCallback onCreateVenue;
  final void Function(String venueId, String venueName) onCreateField;
  final void Function(String fieldId) onOpenField;
  final void Function(String fieldName) onEditField;
  final ValueChanged<VenueModel> onEditVenue;

  const OwnerFieldsTab({
    super.key,
    required this.controller,
    required this.onCreateVenue,
    required this.onCreateField,
    required this.onOpenField,
    required this.onEditField,
    required this.onEditVenue,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.refreshAll(),
      color: AppColors.primary,
      child: Column(
        children: [
          Obx(
            () => VenueSelector(
              venues: controller.venues,
              selectedVenue: controller.selectedVenue.value,
              onVenueSelected: controller.selectVenue,
              onAddVenue: onCreateVenue,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingVenues.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              final selectedVenue = controller.selectedVenue.value;
              if (selectedVenue == null) {
                return _NoVenueState(onCreateVenue: onCreateVenue);
              }

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: VenueStatsCard(venue: selectedVenue),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: OutlinedButton.icon(
                        onPressed: () => onEditVenue(selectedVenue),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Cập nhật venue'),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _FieldsHeader(
                      onCreateField: () => onCreateField(
                        selectedVenue.id,
                        selectedVenue.venueName ?? 'Sân',
                      ),
                    ),
                  ),
                  if (controller.isLoadingFields.value)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else if (controller.fields.isEmpty)
                    SliverToBoxAdapter(
                      child: EmptyFieldsWidget(
                        onAddField: () => onCreateField(
                          selectedVenue.id,
                          selectedVenue.venueName ?? 'Sân',
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
                              onTap: () => onOpenField(field.id ?? ''),
                              onEdit: () => onEditField(
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
    );
  }
}

class _FieldsHeader extends StatelessWidget {
  final VoidCallback onCreateField;

  const _FieldsHeader({required this.onCreateField});

  @override
  Widget build(BuildContext context) {
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
            onTap: onCreateField,
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
}

class _NoVenueState extends StatelessWidget {
  final VoidCallback onCreateVenue;

  const _NoVenueState({required this.onCreateVenue});

  @override
  Widget build(BuildContext context) {
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
              onTap: onCreateVenue,
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
}
