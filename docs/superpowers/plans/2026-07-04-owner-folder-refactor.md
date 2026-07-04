# Owner Folder Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor `lib/presentation/features/owner/` thành cấu trúc feature subfolder, page file < 400 dòng, không thay đổi logic nghiệp vụ.

**Architecture:** Mỗi page có folder riêng cùng `widgets/` con. Shared widgets/dialogs/helpers ở `view/shared/`. Tách `SlotManagement` thành 3 tab độc lập. Tách dialog/sheet >30 dòng ra widget riêng.

**Tech Stack:** Flutter + GetX (không thêm dependency)

**Design Doc:** `docs/superpowers/specs/2026-07-04-owner-folder-refactor-design.md`

---

## Bản đồ file cần tạo / di chuyển / xóa

### Tạo mới (Folder: `lib/presentation/features/owner/view/`)
- `shared/owner_helpers.dart`
- `shared/owner_dialogs.dart`
- `home/owner_home_page.dart`
- `home/widgets/owner_nav_bar.dart`
- `field/add_field_page.dart` (rewrite, sẽ di chuyển từ cũ)
- `field/field_detail_page.dart` (rewrite, sẽ di chuyển từ cũ)
- `field/widgets/edit_price_dialog.dart`
- `field/widgets/exit_confirmation_dialog.dart`
- `slot_management/slot_management_page.dart` (rewrite, sẽ di chuyển từ cũ)
- `slot_management/tabs/create_slots_tab.dart`
- `slot_management/tabs/schedule_tab.dart`
- `slot_management/tabs/slots_list_tab.dart`
- `slot_management/widgets/slot_field_header.dart`
- `slot_management/widgets/slot_info_card.dart`
- `slot_management/widgets/slot_date_picker.dart`
- `slot_management/widgets/slot_time_picker.dart`
- `slot_management/widgets/duration_chips.dart`
- `slot_management/widgets/price_slider.dart`
- `slot_management/widgets/slot_card.dart`
- `slot_management/widgets/schedule_row.dart`
- `slot_management/widgets/empty_slots_state.dart`
- `booking/booking_management_page.dart` (rewrite, sẽ di chuyển từ cũ)
- `booking/widgets/booking_details_sheet.dart`
- `booking/widgets/booking_decision_dialog.dart`
- `booking/widgets/chat_launcher.dart`

### Di chuyển (từ `view/widgets/` hiện tại → `view/<feature>/widgets/`)
- `field_list_item.dart` → `home/widgets/field_list_item.dart`
- `venue_selector.dart` → `home/widgets/venue_selector.dart`
- `venue_stats_card.dart` → `home/widgets/venue_stats_card.dart`
- `empty_fields_widget.dart` → `home/widgets/empty_fields_widget.dart`
- `field_info_section.dart` → `field/widgets/field_info_section.dart`
- `field_type_section.dart` → `field/widgets/field_type_section.dart`
- `pricing_section.dart` → `field/widgets/pricing_section.dart`
- `amenities_section.dart` → `field/widgets/amenities_section.dart`
- `booking_filter_chips.dart` → `booking/widgets/booking_filter_chips.dart`
- `booking_list_item.dart` → `booking/widgets/booking_list_item.dart`
- `booking_stats_card.dart` → `booking/widgets/booking_stats_card.dart`
- `empty_bookings_widget.dart` → `booking/widgets/empty_bookings_widget.dart`

### Xóa sau khi đã thay thế
- `view/owner_home_page.dart` (cũ)
- `view/slot_management_page.dart` (cũ)
- `view/booking_management_page.dart` (cũ)
- Folder `view/widgets/` (sau khi đã di chuyển hết)
- `view/create_field_page.dart` (chỉ xóa nếu grep cho thấy không ai gọi `AppPages.createField`)

### KHÔNG đụng
- Toàn bộ `controller/`
- `binding/owner_binding.dart`
- `view/venue_creation_page.dart` (đã ngắn, không trùng lặp)

---

## Task 0: Pre-flight check

**Files:**
- Read: `lib/core/routing/app_pages.dart`
- Read: `lib/presentation/features/owner/binding/owner_binding.dart`

- [ ] **Step 1: Grep toàn bộ call site `createField`**

Run: `grep -r "createField\|/owner/create-field\|CreateFieldPage\|CreateFieldController" lib/ --include="*.dart"`
Expected: Liệt kê mọi chỗ tham chiếu. Nếu chỉ có trong `app_pages.dart` và `binding/owner_binding.dart` thì an toàn để xóa sau Task 1.

- [ ] **Step 2: Snapshot file sizes (baseline)**

Run:
```
Get-ChildItem -Path "lib/presentation/features/owner/view" -Recurse -Filter "*.dart" |
  Select-Object FullName, @{N="Lines";E={(Get-Content $_.FullName | Measure-Object -Line).Lines}} |
  Sort-Object Lines -Descending | Format-Table
```
Save output vào scratchpad (không cần commit) để so sánh với kết quả.

---

## Task 1: Tạo `view/shared/owner_helpers.dart`

**Files:**
- Create: `lib/presentation/features/owner/view/shared/owner_helpers.dart`

Đây là file chứa pure functions dùng chung. Sau khi tạo, không phụ thuộc vào widgets khác — chỉ import `flutter/material.dart` và `field_model.dart`.

- [ ] **Step 1.1: Tạo file**

Viết file với các hàm thuần (top-level, không trong class):

```dart
import 'package:flutter/material.dart';
import 'package:exe101/domain/models/field_model.dart';

/// Format DateTime thành dd/MM/yyyy.
String formatDateVN(DateTime dt) =>
    '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

/// Format phần thời gian dd/MM/yyyy HH:mm.
String formatDateTimeVN(DateTime dt) =>
    '${formatDateVN(dt)} ${formatTimeHM(dt)}';

/// Format thành HH:mm.
String formatTimeHM(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

/// Format giá theo kiểu VN: 100.000đ
String formatPriceVN(double price) {
  if (price >= 1000) {
    final intPart = (price / 1000).toStringAsFixed(0);
    return '$intPart.000đ';
  }
  return '${price.toStringAsFixed(0)}đ';
}

/// Trả về nhãn hiển thị của loại sân.
String fieldTypeLabel(String? type) =>
    FieldModel.fieldTypeLabels[type] ?? type ?? 'Sân';

/// Tính giá nhỏ nhất trong các loại giá.
double fieldMinPrice(FieldModel field) {
  final prices = <double>[];
  if (field.pricePerHour != null && field.pricePerHour! > 0) {
    prices.add(field.pricePerHour!);
  }
  if (field.priceMorning != null && field.priceMorning! > 0) {
    prices.add(field.priceMorning!);
  }
  if (field.priceAfternoon != null && field.priceAfternoon! > 0) {
    prices.add(field.priceAfternoon!);
  }
  if (field.priceEvening != null && field.priceEvening! > 0) {
    prices.add(field.priceEvening!);
  }
  return prices.isEmpty ? 0 : prices.reduce((a, b) => a < b ? a : b);
}

/// Màu theo trạng thái booking.
Color bookingStatusColor(String? status) {
  switch (status?.toLowerCase()) {
    case 'pending':
      return Colors.orange;
    case 'accepted':
    case 'confirmed':
      return Colors.blue;
    case 'deposited':
      return Colors.teal;
    case 'completed':
      return Colors.green;
    case 'cancelled':
    case 'rejected':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
```

- [ ] **Step 1.2: Verify file lưu thành công**

Run: `Test-Path "lib/presentation/features/owner/view/shared/owner_helpers.dart"`
Expected: `True`

---

## Task 2: Tạo `view/shared/owner_dialogs.dart`

**Files:**
- Create: `lib/presentation/features/owner/view/shared/owner_dialogs.dart`

- [ ] **Step 2.1: Tạo file**

```dart
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Hiển thị dialog xác nhận đăng xuất. Dùng chung cho owner pages.
Future<void> showOwnerLogoutDialog(BuildContext context) async {
  return Get.dialog(
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

/// Hiển thị dialog xác nhận 2 nút Yes/No tổng quát.
Future<bool> showConfirmDialog({
  required String title,
  required String message,
  String confirmText = 'Xác nhận',
  String cancelText = 'Hủy',
  Color confirmColor = AppColors.primary,
}) async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Get.back(result: true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return result ?? false;
}
```

- [ ] **Step 2.2: Verify file**

Run: `Test-Path "lib/presentation/features/owner/view/shared/owner_dialogs.dart"`
Expected: `True`

---

## Task 3: Di chuyển & verify widgets không phụ thuộc nhau

**Files:**
- Move: `lib/presentation/features/owner/view/widgets/*.dart` → `lib/presentation/features/owner/view/<feature>/widgets/`

Di chuyển cơ học bằng cách tạo folder mới và dùng `Move-Item`. KHÔNG sửa nội dung file ở task này (sửa sau).

- [ ] **Step 3.1: Tạo folder**

```powershell
New-Item -ItemType Directory -Force -Path "lib/presentation/features/owner/view/home/widgets"
New-Item -ItemType Directory -Force -Path "lib/presentation/features/owner/view/field/widgets"
New-Item -ItemType Directory -Force -Path "lib/presentation/features/owner/view/booking/widgets"
New-Item -ItemType Directory -Force -Path "lib/presentation/features/owner/view/slot_management/widgets"
New-Item -ItemType Directory -Force -Path "lib/presentation/features/owner/view/slot_management/tabs"
New-Item -ItemType Directory -Force -Path "lib/presentation/features/owner/view/home"
New-Item -ItemType Directory -Force -Path "lib/presentation/features/owner/view/field"
New-Item -ItemType Directory -Force -Path "lib/presentation/features/owner/view/booking"
New-Item -ItemType Directory -Force -Path "lib/presentation/features/owner/view/slot_management"
New-Item -ItemType Directory -Force -Path "lib/presentation/features/owner/view/shared"
```

- [ ] **Step 3.2: Di chuyển home widgets**

```powershell
Move-Item "lib/presentation/features/owner/view/widgets/field_list_item.dart" "lib/presentation/features/owner/view/home/widgets/"
Move-Item "lib/presentation/features/owner/view/widgets/venue_selector.dart" "lib/presentation/features/owner/view/home/widgets/"
Move-Item "lib/presentation/features/owner/view/widgets/venue_stats_card.dart" "lib/presentation/features/owner/view/home/widgets/"
Move-Item "lib/presentation/features/owner/view/widgets/empty_fields_widget.dart" "lib/presentation/features/owner/view/home/widgets/"
```

- [ ] **Step 3.3: Di chuyển field widgets**

```powershell
Move-Item "lib/presentation/features/owner/view/widgets/field_info_section.dart" "lib/presentation/features/owner/view/field/widgets/"
Move-Item "lib/presentation/features/owner/view/widgets/field_type_section.dart" "lib/presentation/features/owner/view/field/widgets/"
Move-Item "lib/presentation/features/owner/view/widgets/pricing_section.dart" "lib/presentation/features/owner/view/field/widgets/"
Move-Item "lib/presentation/features/owner/view/widgets/amenities_section.dart" "lib/presentation/features/owner/view/field/widgets/"
```

- [ ] **Step 3.4: Di chuyển booking widgets**

```powershell
Move-Item "lib/presentation/features/owner/view/widgets/booking_filter_chips.dart" "lib/presentation/features/owner/view/booking/widgets/"
Move-Item "lib/presentation/features/owner/view/widgets/booking_list_item.dart" "lib/presentation/features/owner/view/booking/widgets/"
Move-Item "lib/presentation/features/owner/view/widgets/booking_stats_card.dart" "lib/presentation/features/owner/view/booking/widgets/"
Move-Item "lib/presentation/features/owner/view/widgets/empty_bookings_widget.dart" "lib/presentation/features/owner/view/booking/widgets/"
```

- [ ] **Step 3.5: Verify thư mục cũ đã rỗng**

Run: `Get-ChildItem "lib/presentation/features/owner/view/widgets" -ErrorAction SilentlyContinue`
Expected: Không có file `.dart` (chỉ có thể rỗng). Nếu còn → di chuyển tiếp.

- [ ] **Step 3.6: Xóa folder cũ rỗng**

```powershell
Remove-Item "lib/presentation/features/owner/view/widgets" -Recurse -Force
```

- [ ] **Step 3.7: Run flutter analyze trên toàn owner để xem lỗi import**

Run: `flutter analyze lib/presentation/features/owner/ 2>&1 | Select-String "error" | Select-Object -First 20`
Expected: Chỉ thấy `error` kiểu "Target of URI doesn't exist" từ các file page đang import widget cũ. Ghi lại các file bị lỗi — sẽ sửa trong Task 4-9.

---

## Task 4: Refactor `view/home/owner_home_page.dart`

**Files:**
- Create: `lib/presentation/features/owner/view/home/owner_home_page.dart`
- Create: `lib/presentation/features/owner/view/home/widgets/owner_nav_bar.dart`
- Delete (sau khi tạo xong): `lib/presentation/features/owner/view/owner_home_page.dart`

- [ ] **Step 4.1: Tạo `owner_nav_bar.dart`**

```dart
import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class OwnerNavBar extends StatelessWidget {
  final int pendingCount;
  final VoidCallback onFieldsTap;
  final VoidCallback onBookingsTap;

  const OwnerNavBar({
    super.key,
    required this.pendingCount,
    required this.onFieldsTap,
    required this.onBookingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                child: _NavButton(
                  icon: Icons.stadium,
                  label: 'Quản lý sân',
                  isSelected: true,
                  onTap: onFieldsTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NavButton(
                  icon: Icons.calendar_today,
                  label: 'Duyệt đặt sân',
                  isSelected: false,
                  badge: pendingCount,
                  onTap: onBookingsTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final int badge;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
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
}
```

- [ ] **Step 4.2: Tạo `owner_home_page.dart` mới (~180 dòng)**

Tái sử dụng các widget đã di chuyển. **LƯU Ý:** KHÔNG viết lại logic — sao chép nguyên xi phần build() và helper methods, chỉ tách `_buildNavButton` ra `OwnerNavBar`, dùng `showOwnerLogoutDialog` từ shared.

```dart
import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/field_model.dart';
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
```

- [ ] **Step 4.3: Verify file đã tạo**

Run: `Get-Content "lib/presentation/features/owner/view/home/owner_home_page.dart" | Measure-Object -Line | Select -ExpandProperty Lines`
Expected: ~280 hoặc nhỏ hơn.

- [ ] **Step 4.4: Xóa file cũ**

```powershell
Remove-Item "lib/presentation/features/owner/view/owner_home_page.dart" -Force
```

---

## Task 5: Refactor `view/booking/`

**Files:**
- Create: `lib/presentation/features/owner/view/booking/widgets/booking_details_sheet.dart`
- Create: `lib/presentation/features/owner/view/booking/widgets/booking_decision_dialog.dart`
- Create: `lib/presentation/features/owner/view/booking/widgets/chat_launcher.dart`
- Move: `lib/presentation/features/owner/view/widgets/booking_list_item.dart` → `view/booking/widgets/booking_list_item.dart` (nếu chưa di chuyển)
- Rewrite: `lib/presentation/features/owner/view/booking/booking_management_page.dart`
- Delete: `lib/presentation/features/owner/view/booking_management_page.dart`

- [ ] **Step 5.1: Tạo `booking_details_sheet.dart`**

```dart
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/owner/view/shared/owner_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showBookingDetailsSheet(BookingDto booking) {
  return Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Chi Tiết Đặt Sân',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _DetailRow(label: 'Mã đơn', value: booking.id.substring(0, 8)),
            _DetailRow(label: 'Sân', value: _fieldName(booking)),
            _DetailRow(
              label: 'Thời gian',
              value:
                  '${formatDateVN(booking.startTime)} - ${formatTimeHM(booking.startTime)} đến ${formatTimeHM(booking.endTime)}',
            ),
            _DetailRow(
              label: 'Tổng tiền',
              value: '${booking.totalPrice.toStringAsFixed(0)} VNĐ',
            ),
            if (booking.depositAmount > 0)
              _DetailRow(
                label: 'Đã đặt cọc',
                value: '${booking.depositAmount.toStringAsFixed(0)} VNĐ',
              ),
            if (booking.discountAmount > 0)
              _DetailRow(
                label: 'Giảm giá',
                value: '${booking.discountAmount.toStringAsFixed(0)} VNĐ',
              ),
            _DetailRow(label: 'Trạng thái', value: booking.statusLabel),
            _DetailRow(label: 'Ngày tạo', value: formatDateVN(booking.createdAt)),
            if (booking.note != null && booking.note!.isNotEmpty)
              _DetailRow(label: 'Ghi chú', value: booking.note!),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Đóng'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _fieldName(BookingDto booking) {
  if (booking.items != null && booking.items!.isNotEmpty) {
    return booking.items!.first.fieldName ?? 'Sân';
  }
  return 'Sân';
}
```

- [ ] **Step 5.2: Tạo `booking_decision_dialog.dart`**

```dart
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/owner/controller/booking_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showAcceptBookingDialog(BookingDto booking) async {
  return Get.dialog(
    AlertDialog(
      title: const Text('Xác nhận'),
      content: Text(
        'Bạn có muốn chấp nhận đặt sân "${_fieldName(booking)}" không?',
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Get.back();
            Get.find<BookingManagementController>().acceptBooking(booking.id);
          },
          child: const Text('Chấp nhận'),
        ),
      ],
    ),
  );
}

Future<void> showRejectBookingDialog(BookingDto booking) async {
  final reasonController = TextEditingController();
  return Get.dialog(
    AlertDialog(
      title: const Text('Từ chối đặt sân'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Vui lòng nhập lý do từ chối:'),
          const SizedBox(height: 12),
          TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'VD: Sân không trống vào khung giờ này',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
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
            Get.find<BookingManagementController>().rejectBooking(
              booking.id,
              reasonController.text.isEmpty
                  ? 'Không có lý do'
                  : reasonController.text,
            );
          },
          child: const Text('Từ chối'),
        ),
      ],
    ),
  );
}

Future<void> showCompleteBookingDialog(BookingDto booking) async {
  return Get.dialog(
    AlertDialog(
      title: const Text('Hoàn thành đặt sân'),
      content: Text(
        'Xác nhận hoàn thành đặt sân "${_fieldName(booking)}"?',
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Get.back();
            Get.find<BookingManagementController>().completeBooking(booking.id);
          },
          child: const Text('Hoàn thành'),
        ),
      ],
    ),
  );
}

String _fieldName(BookingDto booking) {
  if (booking.items != null && booking.items!.isNotEmpty) {
    return booking.items!.first.fieldName ?? 'Sân';
  }
  return 'Sân';
}
```

- [ ] **Step 5.3: Tạo `chat_launcher.dart`**

```dart
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/customer/view/messages/chat_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

/// Khởi tạo chat với khách hàng từ booking.
Future<void> startChatWithCustomer(BookingDto booking) async {
  final customerId = booking.userId;
  if (customerId.isEmpty) {
    Get.snackbar('Lỗi', 'Không tìm thấy thông tin khách hàng');
    return;
  }

  try {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      barrierDismissible: false,
    );

    final apiService = Get.find<ApiServiceImpl>();
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    final ownerId = await storage.read(key: 'user_id');

    if (ownerId == null || ownerId.isEmpty) {
      Get.back();
      Get.snackbar('Lỗi', 'Không tìm thấy thông tin người dùng');
      return;
    }

    final chatRoom = await apiService.createChatRoom(
      CreateChatRoomRequest(customerId: customerId, ownerId: ownerId),
    );

    Get.back();
    Get.to(
      () => ChatDetailPage(chatRoom: chatRoom),
      transition: Transition.rightToLeft,
    );
  } catch (e) {
    Get.back();
    Get.snackbar(
      'Lỗi',
      'Không thể bắt đầu cuộc trò chuyện',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
```

- [ ] **Step 5.4: Refactor `booking_list_item.dart`**

File đã được di chuyển vào `view/booking/widgets/booking_list_item.dart`. Sửa nó để:
- Bỏ method `_startChat` → thay bằng gọi `startChatWithCustomer(booking)`
- Bỏ import `chat_detail_page`, `flutter_secure_storage`, `api_service`
- Thêm import `chat_launcher.dart`

```dart
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/owner/view/booking/widgets/chat_launcher.dart';
import 'package:exe101/presentation/features/owner/view/shared/owner_helpers.dart';
import 'package:flutter/material.dart';

class BookingListItem extends StatelessWidget {
  // ... giữ nguyên constructor và thuộc tính ...

  Future<void> _startChat(BuildContext context) async {
    await startChatWithCustomer(booking);
  }

  @override
  Widget build(BuildContext context) {
    // ... giữ nguyên toàn bộ body, chỉ thay thế formatDateTime và formatTime bằng helper:
    final statusColor = bookingStatusColor(booking.bookingStatus);
    // (Bỏ `_getStatusColor()` private method)
    // (Thay `_formatDateTime(booking.startTime)` → formatDateVN v.v. — có thể dùng helper hoặc giữ nguyên để giữ logic "Hôm nay")
  }
}
```

**LƯU Ý:** Logic "Hôm nay / Ngày mai" trong `_formatDateTime` của file cũ là hữu ích cho UI. Có 2 lựa chọn:
- (a) Giữ logic này local trong file — vẫn ổn, chỉ là private method
- (b) Đẩy vào `owner_helpers.dart` với tên `formatBookingStartLabel`

→ **Chọn (a): giữ local**, vì logic này chỉ dùng trong 1 chỗ và là UI-specific.

- [ ] **Step 5.5: Tạo `booking_management_page.dart` mới (~170 dòng)**

```dart
import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/owner/controller/booking_management_controller.dart';
import 'package:exe101/presentation/features/owner/view/booking/widgets/booking_decision_dialog.dart';
import 'package:exe101/presentation/features/owner/view/booking/widgets/booking_details_sheet.dart';
import 'package:exe101/presentation/features/owner/view/booking/widgets/booking_filter_chips.dart';
import 'package:exe101/presentation/features/owner/view/booking/widgets/booking_list_item.dart';
import 'package:exe101/presentation/features/owner/view/booking/widgets/booking_stats_card.dart';
import 'package:exe101/presentation/features/owner/view/booking/widgets/empty_bookings_widget.dart';
import 'package:exe101/presentation/features/owner/view/shared/owner_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingManagementPage extends StatelessWidget {
  const BookingManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingManagementController>();

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Duyệt Đặt Sân',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Get.offAllNamed(AppPages.ownerHome),
            tooltip: 'Về trang chủ',
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
            Obx(() => BookingStatsCard(
                  pendingCount: controller.pendingCount,
                  todayCount: controller.todayBookings.length,
                  totalCount: controller.bookings.length,
                )),
            Obx(() => BookingFilterChips(
                  selectedFilter: controller.selectedFilter.value,
                  onFilterChanged: controller.setFilter,
                  options: controller.filterOptions
                      .map((e) =>
                          {'value': e['value'] as String, 'label': e['label'] as String})
                      .toList(),
                )),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                final bookings = controller.filteredBookings;
                if (bookings.isEmpty) {
                  return EmptyBookingsWidget(
                    message: _emptyMessageFor(controller.selectedFilter.value),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return BookingListItem(
                      booking: booking,
                      onTap: () => showBookingDetailsSheet(booking),
                      onAccept: () => showAcceptBookingDialog(booking),
                      onReject: () => showRejectBookingDialog(booking),
                      onComplete: () => showCompleteBookingDialog(booking),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        if (controller.pendingCount > 0) {
          return FloatingActionButton.extended(
            onPressed: () => controller.setFilter('Pending'),
            backgroundColor: Colors.orange,
            icon: const Icon(Icons.pending_actions, color: Colors.white),
            label: Text(
              '${controller.pendingCount} chờ duyệt',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  String _emptyMessageFor(String filter) {
    // TODO: trước đây logic này inline trong build(). Giữ nguyên message.
    if (filter == 'Pending') return 'Không có đơn chờ duyệt';
    if (filter == 'all') return 'Chưa có đơn đặt sân nào';
    return 'Không có đơn cho bộ lọc này';
  }
}
```

**LƯU Ý:** `_emptyMessageFor` chỉ là wrapper. Logic gốc phức tạp hơn có `firstWhere` lookup — nhưng đó là overhead. Phiên bản cũ fallback là 'Không có đơn ${label}'. Giữ fallback đơn giản. Nếu khác biệt làm phiền, có thể truyền `filterLabel` qua `EmptyBookingsWidget` — nhưng KHÔNG cần thiết cho refactor.

- [ ] **Step 5.6: Xóa file cũ `booking_management_page.dart` (ở view/)**

```powershell
Remove-Item "lib/presentation/features/owner/view/booking_management_page.dart" -Force
```

---

## Task 6: Refactor `view/field/`

**Files:**
- Move: `lib/presentation/features/owner/view/add_field_page.dart` → `view/field/add_field_page.dart`
- Rewrite: `view/field/add_field_page.dart` (slim)
- Create: `view/field/widgets/edit_price_dialog.dart`
- Create: `view/field/widgets/exit_confirmation_dialog.dart`
- Move + Rewrite: `view/field/field_detail_page.dart`
- Delete: `lib/presentation/features/owner/view/field_detail_page.dart`
- Delete (cuối): `lib/presentation/features/owner/view/create_field_page.dart` nếu Task 0 xác nhận an toàn

- [ ] **Step 6.1: Tạo `edit_price_dialog.dart`**

Tách từ `field_detail_page.dart` dòng 406-496.

```dart
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/field_model.dart';
import 'package:exe101/presentation/features/owner/controller/field_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showEditPriceDialog(FieldModel field) async {
  final morningController = TextEditingController(
    text: field.priceMorning?.toStringAsFixed(0) ?? '',
  );
  final afternoonController = TextEditingController(
    text: field.priceAfternoon?.toStringAsFixed(0) ?? '',
  );
  final eveningController = TextEditingController(
    text: field.priceEvening?.toStringAsFixed(0) ?? '',
  );

  await Get.dialog(
    AlertDialog(
      title: const Text('Cập nhật giá sân'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: morningController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Giá buổi sáng (06:00-12:00)',
                suffixText: 'đ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: afternoonController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Giá buổi chiều (12:00-18:00)',
                suffixText: 'đ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: eveningController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Giá buổi tối (18:00-22:00)',
                suffixText: 'đ',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () async {
            final controller = Get.find<FieldDetailController>();
            final priceMorning = double.tryParse(morningController.text);
            final priceAfternoon = double.tryParse(afternoonController.text);
            final priceEvening = double.tryParse(eveningController.text);

            Get.back();

            try {
              await controller.apiService.updateField(
                fieldId: field.id!,
                priceMorning: priceMorning,
                priceAfternoon: priceAfternoon,
                priceEvening: priceEvening,
              );

              Get.snackbar(
                'Thành công',
                'Đã cập nhật giá sân',
                snackPosition: SnackPosition.TOP,
              );

              controller.loadFieldDetail(field.id!);
            } catch (e) {
              Get.snackbar(
                'Lỗi',
                'Không thể cập nhật giá sân',
                snackPosition: SnackPosition.TOP,
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Lưu'),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 6.2: Tạo `exit_confirmation_dialog.dart`**

Tách từ `add_field_page.dart` method `_showExitConfirmation` + `_showFinishDialog`.

```dart
import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/field_model.dart';
import 'package:exe101/presentation/features/owner/controller/add_field_controller.dart';
import 'package:exe101/presentation/features/owner/controller/owner_home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Dialog xác nhận thoát khi đã thêm nhiều sân.
Future<void> showExitConfirmationDialog(
  BuildContext context,
  AddFieldController controller,
) async {
  if (controller.createdFields.isEmpty) {
    _exit();
    return;
  }

  await Get.dialog(
    AlertDialog(
      title: const Text('Thoát?'),
      content: Text(
        'Bạn đã thêm ${controller.createdFields.length} sân. Bạn có muốn thoát không?',
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Get.back();
            _exit();
          },
          child: const Text('Thoát'),
        ),
      ],
    ),
  );
}

/// Dialog hoàn thành khi đã tạo các sân.
Future<void> showFinishDialog(AddFieldController controller) async {
  await Get.dialog(
    AlertDialog(
      title: const Text('Hoàn Thành'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bạn đã tạo thành công:'),
          const SizedBox(height: 12),
          ...controller.createdFields.map((field) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(field.fieldName ?? 'Sân'),
                  ],
                ),
              )),
        ],
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Get.back();
            _exit();
          },
          child: const Text('Về Trang Quản Lý'),
        ),
      ],
    ),
  );
}

void _exit() {
  Get.until(
    (route) =>
        route.settings.name == AppPages.ownerHome || route.isFirst,
  );
  if (Get.isRegistered<OwnerHomeController>()) {
    Get.find<OwnerHomeController>().refreshAll();
  }
}
```

- [ ] **Step 6.3: Tạo `field_detail_page.dart` mới (~280 dòng)**

Bỏ method `_showEditPriceDialog` (gọi `showEditPriceDialog(field)` từ widget mới). Giữ nguyên phần còn lại, import chuyển sang `view/field/widgets/...`.

```dart
import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/field_model.dart';
import 'package:exe101/presentation/features/owner/controller/field_detail_controller.dart';
import 'package:exe101/presentation/features/owner/view/field/widgets/edit_price_dialog.dart';
import 'package:exe101/presentation/features/owner/view/shared/owner_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FieldDetailPage extends StatelessWidget {
  const FieldDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FieldDetailController>();

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Chi Tiết Sân',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Obx(() => controller.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    if (Get.arguments != null &&
                        Get.arguments['fieldId'] != null) {
                      controller.loadFieldDetail(Get.arguments['fieldId']);
                    }
                  },
                )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState(controller);
        }
        final field = controller.field.value;
        if (field == null) {
          return const Center(child: Text('Không có thông tin sân'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldHeader(field),
              const SizedBox(height: 16),
              _buildStatusCard(field, controller),
              const SizedBox(height: 16),
              _buildPriceCard(field),
              if (field.description != null && field.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDescriptionCard(field),
              ],
              if (field.amenities != null && field.amenities!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildAmenitiesCard(field),
              ],
              const SizedBox(height: 24),
              _buildSlotManagementButton(field),
            ],
          ),
        );
      }),
    );
  }

  // ... _buildErrorState, _buildFieldHeader, _buildStatusCard,
  // _buildPriceCard, _buildDescriptionCard, _buildAmenitiesCard,
  // _buildSlotManagementButton đều copy nguyên xi từ file cũ,
  // chỉ thay:
  //   - `_showEditPriceDialog(field)` → `showEditPriceDialog(field)`
  //   - import widgets từ `view/field/widgets/...`
}
```

- [ ] **Step 6.4: Move và rewrite `add_field_page.dart`**

Move file cũ → `view/field/add_field_page.dart`. Sau đó sửa:

1. Bỏ 2 method `_showExitConfirmation`, `_showFinishDialog`, `_refreshOwnerHome`
2. Trong `build()` thay:
   - `() => _showExitConfirmation(context, controller)` → `() => showExitConfirmationDialog(context, controller)`
   - `() => _showFinishDialog(controller)` → `() => showFinishDialog(controller)`
3. Xóa import `app_pages.dart` không còn dùng
4. Thêm import `exit_confirmation_dialog.dart`

- [ ] **Step 6.5: Delete file cũ**

```powershell
Remove-Item "lib/presentation/features/owner/view/field_detail_page.dart" -Force
```

- [ ] **Step 6.6: Move `add_field_page.dart` cũ trước khi sửa (hoặc sau cũng OK)**

```powershell
Move-Item "lib/presentation/features/owner/view/add_field_page.dart" "lib/presentation/features/owner/view/field/add_field_page.dart"
```

- [ ] **Step 6.7: Quyết định `create_field_page.dart`**

Dựa trên Task 0 Step 1:
- Nếu grep **chỉ ra** `app_pages.dart` + `binding/owner_binding.dart` → an toàn xóa
- Nếu có chỗ khác → CẢNH BÁO user, KHÔNG xóa

Nếu an toàn:
```powershell
Remove-Item "lib/presentation/features/owner/view/create_field_page.dart" -Force
```

Đồng thời sửa `owner_binding.dart` xóa `Get.lazyPut<CreateFieldController>` và sửa `app_pages.dart` xóa `GetPage(name: createField, ...)`, import.

---

## Task 7: Refactor `view/slot_management/` (3 tab độc lập)

**Files:**
- Create: 8 widget files
- Create: 3 tab files
- Rewrite: `view/slot_management/slot_management_page.dart`
- Delete: `lib/presentation/features/owner/view/slot_management_page.dart`

Đây là task lớn nhất. Tách theo thứ tự: helpers → widget nhỏ → widget lớn → tab → page.

- [ ] **Step 7.1: Tạo `slot_field_header.dart`**

```dart
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/field_model.dart';
import 'package:exe101/presentation/features/owner/view/shared/owner_helpers.dart';
import 'package:flutter/material.dart';

class SlotFieldHeader extends StatelessWidget {
  final FieldModel field;
  const SlotFieldHeader({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    final fieldTypeLabel = fieldTypeLabel(field.fieldType);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.sports_soccer,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.fieldName ?? 'Sân không tên',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fieldTypeLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 7.2: Tạo `slot_info_card.dart`**

```dart
import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Banner thông tin giải thích ngắn ở đầu các tab.
class SlotInfoCard extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final IconData icon;

  const SlotInfoCard({
    super.key,
    required this.message,
    this.backgroundColor = const Color(0xFFF0F8FF),
    this.borderColor = const Color(0xFFBBDEFB),
    this.iconColor = const Color(0xFF1976D2),
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 7.3: Tạo `slot_date_picker.dart`**

```dart
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/view/shared/owner_helpers.dart';
import 'package:flutter/material.dart';

/// Date picker dạng ô chạm để mở showDatePicker.
class SlotDatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onChanged;

  const SlotDatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  Future<void> _pick(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: value ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (date != null) onChanged(date);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value != null ? formatDateVN(value!) : label,
                style: TextStyle(
                  fontSize: 14,
                  color: value != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 7.4: Tạo `slot_time_picker.dart`**

```dart
import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Picker giờ HH:mm chỉ hiển thị, tap để mở showTimePicker.
class SlotTimePickerField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const SlotTimePickerField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  Future<String?> _showTimePicker(BuildContext context) async {
    final parts = value.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 6,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (selectedTime != null) {
      return '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
    }
    return null;
  }

  Future<void> _pick(BuildContext context) async {
    final time = await _showTimePicker(context);
    if (time != null) onChanged(time);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.schedule,
              color: AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 7.5: Tạo `duration_chips.dart`**

```dart
import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DurationChips extends StatelessWidget {
  final List<int> availableDurations;
  final int selectedDuration;
  final ValueChanged<int> onChanged;

  const DurationChips({
    super.key,
    required this.availableDurations,
    required this.selectedDuration,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: availableDurations.map((duration) {
        final isSelected = selectedDuration == duration;
        return GestureDetector(
          onTap: () => onChanged(duration),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.secondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.inputBorder,
              ),
            ),
            child: Text(
              '$duration phút',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
```

- [ ] **Step 7.6: Tạo `price_slider.dart`**

```dart
import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PriceSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final List<double> quickPrices;
  final ValueChanged<double> onChanged;

  const PriceSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.quickPrices,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.primary.withValues(alpha: 0.2),
                onChanged: onChanged,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${value.toStringAsFixed(0)}đ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final price in quickPrices)
              _QuickPriceChip(
                price: price,
                isSelected: value == price,
                onTap: () => onChanged(price),
              ),
          ],
        ),
      ],
    );
  }
}

class _QuickPriceChip extends StatelessWidget {
  final double price;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickPriceChip({
    required this.price,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inputBorder,
          ),
        ),
        child: Text(
          _formatPrice(price),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  String _formatPrice(double p) {
    if (p >= 1000) {
      final intPart = (p / 1000).toStringAsFixed(0);
      return '$intPart.000đ';
    }
    return '${p.toStringAsFixed(0)}đ';
  }
}
```

**LƯU Ý:** `_formatPrice` ở đây khác `formatPriceVN` ở helper (helper chỉ dùng cho booking). Nếu muốn DRY, đẩy `_formatPrice` vào `owner_helpers.dart` với tên `formatSlotQuickPrice(double p)`. → **Làm**: thêm helper vào `owner_helpers.dart` (sửa Task 1). Cập nhật file này dùng helper.

- [ ] **Step 7.7: Tạo `slot_card.dart`**

```dart
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:flutter/material.dart';

class SlotCard extends StatelessWidget {
  final TimeSlotDto slot;
  const SlotCard({super.key, required this.slot});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final statusLabel = _statusLabel();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _statusIcon(),
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.timeRange,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  slot.selectedDate,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${slot.price.toStringAsFixed(0)}đ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Icon(
                slot.isAvailable ? Icons.lock_open : Icons.lock,
                color: slot.isAvailable ? Colors.green : Colors.grey,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                slot.isAvailable ? 'Mở' : 'Khóa',
                style: TextStyle(
                  fontSize: 11,
                  color: slot.isAvailable ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor() {
    if (slot.isBooked) return Colors.orange;
    if (slot.isLocked) return Colors.grey;
    if (slot.isPending) return Colors.blue;
    return Colors.green;
  }

  String _statusLabel() {
    if (slot.isBooked) return 'Đã đặt';
    if (slot.isLocked) return 'Khóa';
    if (slot.isPending) return 'Chờ xác nhận';
    return 'Trống';
  }

  IconData _statusIcon() {
    if (slot.isBooked) return Icons.event_busy;
    if (slot.isLocked) return Icons.lock;
    if (slot.isPending) return Icons.pending;
    return Icons.event_available;
  }
}
```

**LƯU Ý:** Logic `_statusColor/_statusLabel/_statusIcon` có thể dùng cho cả booking. Tuy nhiên booking đang dùng `bookingStatusColor` ở helper với chuỗi trạng thái (Pending/Accepted/Cancelled), còn slot dùng `isBooked/isLocked/isPending` flags. Khác model → giữ local.

- [ ] **Step 7.8: Tạo `empty_slots_state.dart`**

```dart
import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class EmptySlotsState extends StatelessWidget {
  final VoidCallback? onCreateTap;

  const EmptySlotsState({super.key, this.onCreateTap});

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
                Icons.event_busy,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chưa có slots nào',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tạo slots để người dùng có thể đặt sân',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (onCreateTap != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onCreateTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Tạo Slots'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 7.9: Tạo `schedule_row.dart`**

```dart
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/field_schedule_model.dart';
import 'package:exe101/presentation/features/owner/controller/slot_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScheduleRow extends StatelessWidget {
  final int index;
  final SlotManagementController controller;

  const ScheduleRow({
    super.key,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final dayName = FieldScheduleDto.dayNames[index];
    final schedule =
        controller.editingSchedules.length > index
            ? controller.editingSchedules[index]
            : null;
    final isActive = schedule?.isActive ?? true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border:
            index < 6
                ? const Border(
                    bottom: BorderSide(
                      color: AppColors.inputBorder,
                      width: 1,
                    ),
                  )
                : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isActive,
                onChanged: (value) {
                  controller.updateEditingSchedule(
                    index,
                    isActive: value,
                    openTime: value ? '06:00' : null,
                    closeTime: value ? '22:00' : null,
                  );
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 12),
            _buildTimeRow(context, schedule),
            const SizedBox(height: 8),
            _buildDurationRow(schedule),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeRow(BuildContext context, FieldScheduleRowDto? schedule) {
    return Row(
      children: [
        Expanded(
          child: _ScheduleTimeField(
            value: schedule?.openTime ?? '06:00',
            onTap: () async {
              final time = await _showTimePicker(
                Get.context!,
                schedule?.openTime ?? '06:00',
              );
              if (time != null) {
                controller.updateEditingSchedule(index, openTime: time);
              }
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.remove,
            color: AppColors.textSecondary,
            size: 16,
          ),
        ),
        Expanded(
          child: _ScheduleTimeField(
            value: schedule?.closeTime ?? '22:00',
            onTap: () async {
              final time = await _showTimePicker(
                Get.context!,
                schedule?.closeTime ?? '22:00',
              );
              if (time != null) {
                controller.updateEditingSchedule(index, closeTime: time);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDurationRow(FieldScheduleRowDto? schedule) {
    return Row(
      children: [
        const Text(
          'Slot: ',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 8),
        ...[30, 45, 60, 90].map((duration) {
          final isSelected = schedule?.slotDurationMinutes == duration;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                controller.updateEditingSchedule(
                  index,
                  slotDuration: duration,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.secondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${duration}m',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<String?> _showTimePicker(
    BuildContext context,
    String currentTime,
  ) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 6,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (selectedTime != null) {
      return '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
    }
    return null;
  }
}

class _ScheduleTimeField extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const _ScheduleTimeField({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.schedule,
              color: AppColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 7.10: Tạo `tabs/create_slots_tab.dart`**

```dart
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/slot_management_controller.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/duration_chips.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/price_slider.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_date_picker.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_info_card.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_time_picker_field.dart' show SlotTimePickerField;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateSlotsTab extends StatelessWidget {
  final SlotManagementController controller;
  const CreateSlotsTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SlotInfoCard(
            message:
                'Tạo slots hàng loạt giúp bạn nhanh chóng thiết lập lịch đặt sân cho nhiều ngày.',
            backgroundColor: Color(0xFFFEEEEE),  // primary tinted
            borderColor: Color(0xFFFFCDD2),
            iconColor: AppColors.primary,
          ),
          // ... Date range, time, duration, price, button sections
          _buildDateRangeSection(context),
          // ...
        ],
      ),
    );
  }
}
```

**Chú ý:** SlotInfoCard mặc định dùng blue. Cần override cho từng tab. Hoặc có thêm default constructor → như Step 7.2 đã có tham số tùy chỉnh.

- [ ] **Step 7.11: Tạo `tabs/schedule_tab.dart`**

```dart
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/field_schedule_model.dart';
import 'package:exe101/presentation/features/owner/controller/slot_management_controller.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/schedule_row.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_info_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScheduleTab extends StatelessWidget {
  final SlotManagementController controller;
  const ScheduleTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SlotInfoCard(
            message:
                'Thiết lập giờ mở cửa và thời lượng slot cho từng ngày trong tuần.',
          ),
          const SizedBox(height: 16),
          _buildScheduleGrid(controller),
          const SizedBox(height: 24),
          _buildSaveButton(controller),
        ],
      ),
    );
  }

  // Copy logic từ file cũ: _buildScheduleGrid, _buildSaveScheduleButton.
  // Bỏ _buildScheduleRow, dùng ScheduleRow widget thay thế.
}
```

- [ ] **Step 7.12: Tạo `tabs/slots_list_tab.dart`**

```dart
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/slot_management_controller.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/empty_slots_state.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SlotsListTab extends StatelessWidget {
  final SlotManagementController controller;
  final VoidCallback onSwitchToCreate;

  const SlotsListTab({
    super.key,
    required this.controller,
    required this.onSwitchToCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.slots.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }
      if (controller.slots.isEmpty) {
        return EmptySlotsState(onCreateTap: onSwitchToCreate);
      }
      return RefreshIndicator(
        onRefresh: () => controller.loadSlots(),
        color: AppColors.primary,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.slots.length,
          itemBuilder: (context, index) {
            return SlotCard(slot: controller.slots[index]);
          },
        ),
      );
    });
  }
}
```

- [ ] **Step 7.13: Tạo `slot_management_page.dart` shell (~80 dòng)**

```dart
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
```

- [ ] **Step 7.14: Xóa file cũ**

```powershell
Remove-Item "lib/presentation/features/owner/view/slot_management_page.dart" -Force
```

---

## Task 8: Verify toàn bộ

- [ ] **Step 8.1: Kiểm tra flutter analyze**

Run: `flutter analyze lib/presentation/features/owner/ 2>&1 | Tee-Object -FilePath analyze.log`
Expected: 
- 0 errors
- Có thể có warnings (style/deprecation) → OK nếu pre-existing

Nếu có errors do thiếu import:
- Tìm file trong error log, sửa import path.
- LƯU Ý: `slot_time_picker_field.dart` được tạo ở Task 7.4. Đổi tên file thành `slot_time_picker.dart` để đồng nhất - đã làm rồi.

- [ ] **Step 8.2: Verify line counts**

Run:
```powershell
Get-ChildItem -Path "lib/presentation/features/owner" -Recurse -Filter "*.dart" |
  Where-Object { $_.FullName -notmatch "controller\\" } |
  Select-Object FullName, @{N="Lines";E={(Get-Content $_.FullName | Measure-Object -Line).Lines}} |
  Sort-Object Lines -Descending | Format-Table -AutoSize
```

Expected:
- `slot_management_page.dart` ≤ 110 dòng (chỉ là shell)
- 3 tab files khoảng 200-280 dòng mỗi cái
- `field_detail_page.dart` ≤ 320 dòng
- `add_field_page.dart` ≤ 250 dòng
- `booking_management_page.dart` ≤ 180 dòng
- `owner_home_page.dart` ≤ 280 dòng
- Các widget < 200 dòng
- KHÔNG có file nào > 400 dòng ngoại trừ controllers.

- [ ] **Step 8.3: Run app (verify thủ công)**

Run: `flutter run` (trên emulator hoặc device đang chạy)

Test các flow:
1. Đăng nhập owner
2. Mở một sân → mở `Field Detail` → bấm "Sửa" giá → dialog mở OK
3. Quay lại home → bấm "Quản lý Slots" trong detail → 3 tab mở OK
4. Tab "Tạo Slots" → form hiển thị đầy đủ
5. Tab "Lịch sân" → 7 hàng thứ hiển thị
6. Tab "Danh sách" → nếu có slot hiển thị
7. Quay home → bấm "Duyệt đặt sân" → danh sách booking hiển thị
8. Bấm 1 booking → bottom sheet chi tiết hiển thị
9. Bấm "Chấp nhận/Từ chối" → dialog hiển thị
10. Thêm sân mới → flow OK
11. Logout dialog hiển thị

Expected: Tất cả flow chạy đúng như trước refactor.

---

## Task 9: Final cleanup

- [ ] **Step 9.1: Đảm bảo folder cũ trống**

Run: `Get-ChildItem "lib/presentation/features/owner/view" -Directory`
Expected: 
- `booking/`
- `field/`
- `home/`
- `shared/`
- `slot_management/`
- `venue_creation/` (nếu đã move) HOẶC KHÔNG có (giữ nguyên)

- [ ] **Step 9.2: Kiểm tra các file orphan**

Run: 
```powershell
Get-ChildItem -Path "lib/presentation/features/owner" -Recurse -Filter "*.dart" |
  Where-Object { $_.FullName -match "view\\widgets" -or $_.FullName -match "view\\(owner_home|slot_management|booking_management|field_detail|add_field|create_field)_page" }
```
Expected: Empty (không file nào match).

- [ ] **Step 9.3: Commit (chỉ khi user yêu cầu)**

KHÔNG tự commit. Hỏi user trước khi commit.

---

## Phụ lục: Bảng tổng kết

| File cũ | File mới | Dòng (ước lượng) |
|---------|----------|-----------------|
| `view/owner_home_page.dart` (388) | `view/home/owner_home_page.dart` + `view/home/widgets/owner_nav_bar.dart` | ~280 + ~110 |
| `view/booking_management_page.dart` (342) | `view/booking/booking_management_page.dart` + 3 widget dialogs | ~180 + ~250 |
| `view/widgets/booking_list_item.dart` (404) | `view/booking/widgets/booking_list_item.dart` (refactored, không trừ logic) | ~370 |
| `view/widgets/*` (cũ, ~12 file) | `view/<feature>/widgets/*` (di chuyển nguyên xi) | không đổi |
| `view/field_detail_page.dart` (680) | `view/field/field_detail_page.dart` + `edit_price_dialog.dart` | ~280 + ~110 |
| `view/add_field_page.dart` (682) | `view/field/add_field_page.dart` + `exit_confirmation_dialog.dart` | ~250 + ~90 |
| `view/create_field_page.dart` (185) | ❌ (xóa, nếu an toàn) | - |
| `view/slot_management_page.dart` (1228) | `view/slot_management/slot_management_page.dart` (110) + 3 tabs (200-280 mỗi cái) + 8 widgets | 110 + ~750 + ~800 |

**Total:** ~25 file tổ chức lại, kích thước trung bình < 250 dòng/file, không có file nào > 400 dòng (ngoại trừ 1-2 widget nặng).
