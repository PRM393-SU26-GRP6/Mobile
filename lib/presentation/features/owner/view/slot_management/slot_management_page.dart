import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/slot_management_controller.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/tabs/create_slots_tab.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/tabs/schedule_tab.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/tabs/slots_list_tab.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_field_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SlotManagementPage extends StatefulWidget {
  const SlotManagementPage({super.key});

  @override
  State<SlotManagementPage> createState() => _SlotManagementPageState();
}

class _SlotManagementPageState extends State<SlotManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final controller = Get.find<SlotManagementController>();
      if (_tabController.index == 1) {
        controller.loadSchedule();
      } else if (_tabController.index == 2) {
        controller.loadSlots();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SlotManagementController>();

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Quản lý Slots',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final field = controller.field.value;

        if (controller.isLoading.value && field == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return Column(
          children: [
            if (field != null) SlotFieldHeader(field: field),
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Tạo Slots'),
                  Tab(text: 'Lịch sân'),
                  Tab(text: 'Danh sách'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  CreateSlotsTab(controller: controller),
                  ScheduleTab(controller: controller),
                  SlotsListTab(
                    controller: controller,
                    onSwitchToCreate: () => _tabController.animateTo(0),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
