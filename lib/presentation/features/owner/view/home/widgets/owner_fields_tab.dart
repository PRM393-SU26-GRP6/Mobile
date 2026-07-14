import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:exe101/presentation/features/owner/controller/owner_home_controller.dart';
import 'package:exe101/presentation/features/owner/view/home/widgets/empty_fields_widget.dart';
import 'package:exe101/presentation/features/owner/view/home/widgets/field_list_item.dart';
import 'package:exe101/presentation/features/owner/view/home/widgets/fields_header.dart';
import 'package:exe101/presentation/features/owner/view/home/widgets/no_venue_state.dart';
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
                return NoVenueState(onCreateVenue: onCreateVenue);
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
                        label: const Text('Cập nhật cụm sân'),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: FieldsHeader(
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
