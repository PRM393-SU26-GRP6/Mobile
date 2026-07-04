# Owner Folder Refactor Design

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tái cấu trúc `lib/presentation/features/owner/` để các file page không vượt quá ~300 dòng, code dễ đọc, dễ bảo trì, đồng thời tái sử dụng được các widget/dialog lặp lại. **Không thay đổi logic nghiệp vụ**.

**Architecture:** Tổ chức lại theo feature subfolder trong `view/`. Mỗi page lớn sẽ được tách thành: page shell + tabs/widgets con + dialogs. Các widget & helper dùng chung được gom vào `view/shared/`.

**Tech Stack:** Flutter + GetX (đã có sẵn), không thêm dependency mới.

**Phạm vi:** Chỉ trong `lib/presentation/features/owner/`. Không động vào các feature khác.

---

## Cấu trúc hiện tại & vấn đề

### Số liệu file quá dài (source: `wc -l`)

| File | Dòng | Vấn đề chính |
|------|-------|--------------|
| `view/slot_management_page.dart` | 1228 | 3 tab độc lập nhét chung, helper UI trùng lặp |
| `view/add_field_page.dart` | 682 | Form + dialogs + helper UI |
| `view/field_detail_page.dart` | 680 | Page + inline dialog edit price (~90 dòng) |
| `view/widgets/booking_list_item.dart` | 404 | Card + dialog chat (~70 dòng) |
| `view/owner_home_page.dart` | 388 | UI + empty states + nav button + dialog logout |
| `view/venue_creation_page.dart` | 361 | OK nếu giữ nguyên, đã là leaf page |
| `view/booking_management_page.dart` | 342 | Page + 4 dialog/sheet inline |

### Trùng lặp phát hiện

- `_showLogoutDialog` xuất hiện ở 2 file (`owner_home_page.dart`, `booking_management_page.dart`)
- `formatDate`, `formatTime` ở `booking_management_page.dart` & `booking_list_item.dart` trùng pattern
- `_buildTextField` ở `add_field_page.dart` & gần giống các TextField ở `slot_management_page.dart`
- Logic `_buildSectionTitle` trùng ở `pricing_section.dart`, `field_info_section.dart`, `field_type_section.dart`, `amenities_section.dart`

### Tách `add_field_page.dart` ↔ `create_field_page.dart`

- Cả `AddFieldPage` (682 dòng) và `CreateFieldPage` (185 dòng) đều đang bind trong `app_pages.dart`.
- `AddFieldPage` được bind ở `AppPages.addField`, `CreateFieldPage` ở `AppPages.createField`.
- `OwnerHomePage._navigateToCreateField` thực tế route sang `AppPages.addField`, nghĩa là người dùng chỉ chạm vào `AddFieldPage`.
- **Quyết định (đã chốt với user):**
  - Consolidate UI = lấy `AddFieldPage` (đầy đủ hơn) + các section widgets (gọn) của `CreateFieldPage`.
  - Giữ route `AppPages.addField` (đang được dùng) — KHÔNG xóa route name `createField` để không phá các chỗ khác có thể trỏ tới (sẽ grep lại khi execute).
  - File kết quả: chỉ còn `field/add_field_page.dart` (canonical) sử dụng `AddFieldController`. `CreateFieldPage` + `CreateFieldController` chỉ xóa nếu an toàn (xác nhận cuối cùng lúc execute).

---

## Cấu trúc đích

```
lib/presentation/features/owner/
├── binding/
│   └── owner_binding.dart                              # (giữ nguyên)
├── controller/
│   ├── owner_home_controller.dart                     # (giữ nguyên)
│   ├── venue_creation_controller.dart                 # (giữ nguyên)
│   ├── add_field_controller.dart                      # (giữ nguyên, bỏ create_field_controller cũ)
│   ├── field_detail_controller.dart                    # (giữ nguyên)
│   ├── slot_management_controller.dart                # (giữ nguyên)
│   └── booking_management_controller.dart             # (giữ nguyên)
└── view/
    ├── shared/                                        # widget/helper dùng chung
    │   ├── owner_dialogs.dart                         # showLogoutDialog, confirmDialog, infoDialog
    │   ├── owner_helpers.dart                         # formatDate, formatTime, formatPrice, statusColor, statusLabel
    │   └── owner_scaffold.dart                        # chỉ là helper lấy AppBar style đồng nhất
    │
    ├── home/
    │   ├── owner_home_page.dart                       # shell chính (≈150 dòng)
    │   └── widgets/
    │       ├── venue_selector.dart                    # giữ
    │       ├── venue_stats_card.dart                   # giữ
    │       ├── field_list_item.dart                    # giữ
    │       ├── empty_fields_widget.dart                # giữ
    │       └── owner_nav_bar.dart                     # tách từ _buildNavButton
    │
    ├── venue_creation/
    │   └── venue_creation_page.dart                   # giữ nguyên
    │
    ├── field/
    │   ├── add_field_page.dart                        # ≈200 dòng, dùng các section widgets
    │   ├── field_detail_page.dart                     # ≈250 dòng, dùng edit_price_dialog
    │   └── widgets/
    │       ├── field_info_section.dart                # giữ
    │       ├── field_type_section.dart                # giữ
    │       ├── pricing_section.dart                   # giữ
    │       ├── amenities_section.dart                 # giữ
    │       ├── edit_price_dialog.dart                 # tách từ field_detail_page
    │       └── exit_confirmation_dialog.dart          # tách từ add_field_page
    │
    ├── slot_management/
    │   ├── slot_management_page.dart                  # TabBar shell (≈80 dòng)
    │   ├── tabs/
    │   │   ├── create_slots_tab.dart                  # (≈280 dòng)
    │   │   ├── schedule_tab.dart                      # (≈250 dòng)
    │   │   └── slots_list_tab.dart                    # (≈220 dòng)
    │   └── widgets/
    │       ├── slot_field_header.dart                 # _buildFieldHeader
    │       ├── slot_info_card.dart                    # info banner trên cùng
    │       ├── slot_date_picker.dart                  # _buildDatePicker
    │       ├── slot_time_picker.dart                  # _buildTimePicker + _showTimePicker
    │       ├── duration_chips.dart                    # _buildDurationSection
    │       ├── price_slider.dart                      # _buildPriceSection + quick price
    │       ├── slot_card.dart                         # _buildSlotCard
    │       ├── schedule_row.dart                      # _buildScheduleRow
    │       └── empty_slots_state.dart                 # _buildEmptySlotsState
    │
    └── booking/
        ├── booking_management_page.dart               # ≈180 dòng
        └── widgets/
            ├── booking_filter_chips.dart              # giữ
            ├── booking_list_item.dart                 # card-only, chat tách ra
            ├── booking_stats_card.dart                # giữ
            ├── empty_bookings_widget.dart             # giữ
            ├── booking_details_sheet.dart             # tách bottom sheet từ _showBookingDetails
            ├── booking_decision_dialog.dart           # dialog accept/reject/complete
            └── chat_launcher.dart                     # _startChat từ booking_list_item
```

---

## Các quyết định thiết kế

### 1. Tổ chức theo feature, không theo layer
Mỗi page có folder riêng cùng `widgets/` con. Shared UI gom ở `view/shared/`. Tránh tạo `view/widgets/` toàn cục vì rất khó tìm.

### 2. Tab = widget độc lập
3 tab của `SlotManagementPage` được tách thành 3 widget class. `slot_management_page.dart` chỉ giữ TabBar + Obx routing tab. Mỗi tab nhận controller qua constructor.

```dart
class CreateSlotsTab extends StatelessWidget {
  final SlotManagementController controller;
  const CreateSlotsTab({required this.controller, super.key});
  ...
}
```

### 3. Dialog/Sheet tách widget
Bất kỳ dialog hoặc bottom sheet nào có >30 dòng trong page file → tách widget file riêng. Page chỉ gọi `Get.dialog/showModalBottomSheet(WIDGET())`.

### 4. Helpers thuần function → `shared/owner_helpers.dart`
- `String formatDateVN(DateTime dt)` 
- `String formatTimeHM(DateTime dt)`
- `String formatPriceVN(double price)`
- `Color bookingStatusColor(String? status)`
- `String bookingStatusLabel(String? status)`
- `String fieldLabel(String? type)`
- `double fieldMinPrice(FieldModel field)`

### 5. Logout dialog → shared
`showOwnerLogoutDialog(BuildContext)` trong `shared/owner_dialogs.dart`.

### 6. Không thay đổi Controller & Binding
Controllers giữ nguyên API, không sửa logic. `owner_binding.dart` giữ nguyên.

### 7. Không viết test (theo yêu cầu user)
Verify bằng `flutter analyze` + chạy thử app trên emulator/device để chắc chắn không regress navigation / state.

### 8. Xử lý `create_field_page.dart`
- Cả hai vẫn bind trong routing. `OwnerHomePage._navigateToCreateField` chỉ route sang `AppPages.addField`. `CreateFieldPage` không ai navigate tới qua navigation logic, nhưng route vẫn tồn tại.
- Khi execute: grep toàn bộ `AppPages.createField` trong codebase. Nếu **KHÔNG có** call site nào khác (ngoài `app_pages.dart`), thì có thể xóa an toàn. Nếu có chỗ dùng (kể cả trong JSON/test), CẢNH BÁO user và dừng.

### 9. Không dùng GetView thay GetX pattern hiện tại
Giữ `Get.find<>()` style của code hiện tại để không phải refactor controller gọi lại.

---

## Những thay đổi tổng quát

### File mới (dự kiến ~18 file)
- `view/shared/owner_dialogs.dart`
- `view/shared/owner_helpers.dart`
- `view/home/owner_nav_bar.dart`
- `view/field/widgets/edit_price_dialog.dart`
- `view/field/widgets/exit_confirmation_dialog.dart`
- `view/slot_management/tabs/create_slots_tab.dart`
- `view/slot_management/tabs/schedule_tab.dart`
- `view/slot_management/tabs/slots_list_tab.dart`
- `view/slot_management/widgets/slot_field_header.dart`
- `view/slot_management/widgets/slot_info_card.dart`
- `view/slot_management/widgets/slot_date_picker.dart`
- `view/slot_management/widgets/slot_time_picker.dart`
- `view/slot_management/widgets/duration_chips.dart`
- `view/slot_management/widgets/price_slider.dart`
- `view/slot_management/widgets/slot_card.dart`
- `view/slot_management/widgets/schedule_row.dart`
- `view/slot_management/widgets/empty_slots_state.dart`
- `view/booking/widgets/booking_details_sheet.dart`
- `view/booking/widgets/booking_decision_dialog.dart`
- `view/booking/widgets/chat_launcher.dart`

### File xóa/di chuyển
- `view/widgets/` (cũ) → phân rã vào các feature/widgets trên
- `view/booking_list_item.dart` (ở widgets cũ) → `view/booking/widgets/`
- `view/slot_management_page.dart` (cũ) → 1 shell + 3 tabs + 8 widgets
- `view/field_detail_page.dart` (cũ) → page rút gọn + `edit_price_dialog.dart`
- `view/add_field_page.dart` (cũ) → page rút gọn + `exit_confirmation_dialog.dart`
- `view/owner_home_page.dart` (cũ) → shell + `owner_nav_bar.dart`
- `view/booking_management_page.dart` (cũ) → page rút gọn + 3 dialog/sheet widgets

### File không đổi
- Toàn bộ `controller/`
- `binding/owner_binding.dart`
- `view/venue_creation/venue_creation_page.dart`

---

## Rủi ro & giảm thiểu

| Rủi ro | Giảm thiểu |
|--------|------------|
| Quên import trong tab → mất context | Sau mỗi task, chạy `flutter analyze lib/presentation/features/owner/` |
| Obx không reactive khi tách widget | Truyền controller qua constructor; bên trong vẫn wrap `Obx()` chứ không snapshot |
| Phá vỡ routing tên (Get.toNamed) | Không đổi tên route, không đổi tên class page |
| Empty widget có lúc giữ nguyên | Wrap constructor tương thích |
| Mất build context cho dialog Get.context | Dùng `Get.context!` hoặc truyền context qua constructor cho dialog widget |

---

## Tiêu chí hoàn thành

1. `flutter analyze` không có lỗi (warning vẫn OK nếu đã có sẵn)
2. Không file .dart nào trong `view/` quá 400 dòng
3. App khởi động bình thường, không crash khi navigate các màn owner
4. Các chức năng nghiệp vụ (CRUD venue, field, slot, booking) hoạt động giống trước
