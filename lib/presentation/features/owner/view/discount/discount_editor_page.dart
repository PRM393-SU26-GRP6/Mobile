import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/discount_model.dart';
import 'package:exe101/presentation/features/owner/controller/discount_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class DiscountEditorPage extends StatefulWidget {
  const DiscountEditorPage({super.key});

  @override
  State<DiscountEditorPage> createState() => _DiscountEditorPageState();
}

class _DiscountEditorPageState extends State<DiscountEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<DiscountManagementController>();

  DiscountDto? _existingDiscount;

  late TextEditingController _codeCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _valueCtrl;
  late TextEditingController _minAmountCtrl;
  late TextEditingController _maxAmountCtrl;
  late TextEditingController _usageLimitCtrl;

  String _discountType = 'Percentage';
  bool _isActive = true;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    _existingDiscount = Get.arguments as DiscountDto?;

    _codeCtrl = TextEditingController(text: _existingDiscount?.code ?? '');
    _nameCtrl = TextEditingController(text: _existingDiscount?.name ?? '');
    _valueCtrl = TextEditingController(text: _existingDiscount?.value.toString() ?? '');
    _minAmountCtrl = TextEditingController(text: _existingDiscount?.minBookingAmount.toString() ?? '0');
    _maxAmountCtrl = TextEditingController(text: _existingDiscount?.maxDiscountAmount.toString() ?? '0');
    _usageLimitCtrl = TextEditingController(text: _existingDiscount?.usageLimit.toString() ?? '100');

    if (_existingDiscount != null) {
      _discountType = _existingDiscount!.discountType ?? 'Percentage';
      _isActive = _existingDiscount!.isActive;
      _startDate = _existingDiscount!.startDate;
      _endDate = _existingDiscount!.endDate;
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _valueCtrl.dispose();
    _minAmountCtrl.dispose();
    _maxAmountCtrl.dispose();
    _usageLimitCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    final newDto = DiscountDto(
      discountId: _existingDiscount?.discountId ?? const Uuid().v4(),
      ownerId: _existingDiscount?.ownerId ?? '', // api will ignore/override or we need to pass current owner
      code: _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      discountType: _discountType,
      value: double.tryParse(_valueCtrl.text) ?? 0,
      minBookingAmount: double.tryParse(_minAmountCtrl.text) ?? 0,
      maxDiscountAmount: double.tryParse(_maxAmountCtrl.text) ?? 0,
      usageLimit: int.tryParse(_usageLimitCtrl.text) ?? 100,
      usedCount: _existingDiscount?.usedCount ?? 0,
      startDate: _startDate,
      endDate: _endDate,
      isActive: _isActive,
    );

    bool success;
    if (_existingDiscount != null) {
      success = await _controller.updateDiscount(newDto.discountId, newDto);
    } else {
      success = await _controller.createDiscount(newDto);
    }

    Get.back(); // close loading

    if (success) {
      Get.back(); // return to list
      Get.snackbar('Thành công', 'Lưu khuyến mãi thành công', backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar('Lỗi', 'Không thể lưu khuyến mãi', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _existingDiscount != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa Khuyến Mãi' : 'Tạo Khuyến Mãi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _onSave,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _codeCtrl,
                decoration: const InputDecoration(labelText: 'Mã giảm giá (Code)'),
                validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập mã' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Tên chương trình'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _discountType,
                decoration: const InputDecoration(labelText: 'Loại giảm giá'),
                items: const [
                  DropdownMenuItem(value: 'Percentage', child: Text('Phần trăm (%)')),
                  DropdownMenuItem(value: 'Fixed', child: Text('Tiền mặt (VND)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _discountType = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _valueCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Trị giá (VD: 20 hoặc 50000)'),
                validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập trị giá' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minAmountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Đơn hàng tối thiểu'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxAmountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Giảm tối đa'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _usageLimitCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Số lượng mã'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Từ ngày'),
                        child: Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Đến ngày'),
                        child: Text('${_endDate.day}/${_endDate.month}/${_endDate.year}'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Kích hoạt'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Lưu thông tin', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
