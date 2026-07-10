import 'package:dio/dio.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';
import 'package:exe101/presentation/features/customer/view/booking/widgets/booking_info_row.dart';
import 'package:exe101/presentation/features/customer/view/booking/widgets/booking_success_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingConfirmDialog extends StatefulWidget {
  final List<String> slotIds;
  final double totalPrice;
  final String venueName;
  final String fieldName;
  final int slotCount;

  const BookingConfirmDialog({
    super.key,
    required this.slotIds,
    required this.totalPrice,
    required this.venueName,
    required this.fieldName,
    required this.slotCount,
  });

  static Future<bool> show({
    required List<String> slotIds,
    required double totalPrice,
    required String venueName,
    required String fieldName,
    required int slotCount,
  }) async {
    final result = await Get.dialog<bool>(
      BookingConfirmDialog(
        slotIds: slotIds,
        totalPrice: totalPrice,
        venueName: venueName,
        fieldName: fieldName,
        slotCount: slotCount,
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  @override
  State<BookingConfirmDialog> createState() => _BookingConfirmDialogState();
}

class _BookingConfirmDialogState extends State<BookingConfirmDialog> {
  final _discountController = TextEditingController();
  final _noteController = TextEditingController();

  _State _state = _State.idle;
  String _errorMessage = '';
  final BookingController _bookingController = Get.find<BookingController>();

  @override
  void initState() {
    super.initState();
    _bookingController.clearDiscount(widget.totalPrice);
  }

  @override
  void dispose() {
    _discountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _onValidateDiscount() async {
    final code = _discountController.text.trim();
    if (code.isEmpty) {
      _bookingController.clearDiscount(widget.totalPrice);
      return;
    }
    setState(() {
      _state = _State.loading;
      _errorMessage = '';
    });
    // For validateDiscount, we might need fieldId. We'll pass null or fetch it.
    await _bookingController.validateDiscount(
      code: code,
      fieldId: null, // Ideally we have fieldId, but let's pass null or from widget
      slotIds: widget.slotIds,
      totalAmount: widget.totalPrice,
    );
    setState(() => _state = _State.idle);
  }

  Future<void> _onConfirm() async {
    final discountCode = _discountController.text.trim();
    final note = _noteController.text.trim();

    setState(() {
      _state = _State.loading;
      _errorMessage = '';
    });

    try {
      await _bookingController.createBooking(
        slotIds: widget.slotIds,
        discountCode: _bookingController.isDiscountValid.value ? _bookingController.discountCode.value : '',
        note: note.isEmpty ? '' : note,
      );

      setState(() => _state = _State.success);
    } catch (e) {
      String msg;
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final serverMsg = e.response?.data?['message'] ?? '';
        if (statusCode == 409) {
          msg = 'Slot đã được đặt, vui lòng chọn lại';
        } else if (statusCode == 400) {
          msg =
              'Dữ liệu không hợp lệ${serverMsg.isNotEmpty ? ': $serverMsg' : ''}';
        } else if (statusCode == 401) {
          msg = 'Phiên đăng nhập hết hạn';
        } else if (statusCode != null) {
          msg = 'Lỗi $statusCode${serverMsg.isNotEmpty ? ': $serverMsg' : ''}';
        } else {
          msg = 'Không thể kết nối server: ${e.message}';
        }
      } else {
        msg = 'Đặt sân thất bại: $e';
      }
      setState(() {
        _state = _State.error;
        _errorMessage = msg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_state == _State.success) ...[
              const BookingSuccessView(),
            ] else ...[
              _buildHeader(),
              const SizedBox(height: 16),
              _buildInfo(),
              const SizedBox(height: 16),
              _buildDiscountField(),
              const SizedBox(height: 12),
              _buildNoteField(),
              const SizedBox(height: 8),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _buildActions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.calendar_month,
              color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Text(
            'Xác nhận đặt sân',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (_state != _State.loading)
          GestureDetector(
            onTap: () => Get.back(result: false),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close,
                  color: AppColors.textSecondary, size: 22),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          BookingInfoRow(
            icon: Icons.sports_soccer,
            label: 'Sân',
            value: widget.fieldName,
            valueIcon: Icons.stadium,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: AppColors.inputBorder),
          ),
          BookingInfoRow(
            icon: Icons.location_on,
            label: 'Địa điểm',
            value: widget.venueName,
            valueIcon: Icons.map,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: AppColors.inputBorder),
          ),
          BookingInfoRow(
            icon: Icons.access_time,
            label: 'Số khung giờ',
            value: '${widget.slotCount} khung',
            valueIcon: Icons.timer,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: AppColors.inputBorder),
          ),
          Obx(() {
            if (_bookingController.isDiscountValid.value) {
              return Column(
                children: [
                  BookingInfoRow(
                    icon: Icons.money_off,
                    label: 'Giảm giá',
                    value: '-${_bookingController.discountAmount.value.toStringAsFixed(0)}đ',
                    valueIcon: Icons.local_offer,
                    valueColor: Colors.green,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, color: AppColors.inputBorder),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          Obx(() => BookingInfoRow(
                icon: Icons.payments,
                label: 'Tổng tiền',
                value: '${_bookingController.finalPrice.value.toStringAsFixed(0)}đ',
                valueIcon: Icons.receipt_long,
                isBold: true,
                valueColor: AppColors.primary,
              )),
        ],
      ),
    );
  }

  Widget _buildDiscountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _discountController,
                enabled: _state != _State.loading,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Mã giảm giá',
                  labelStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500),
                  hintText: 'Nhập mã giảm giá',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: AppColors.secondary,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  prefixIcon: const Icon(Icons.discount_outlined,
                      size: 18, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _state == _State.loading ? null : _onValidateDiscount,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Áp dụng'),
            ),
          ],
        ),
        Obx(() {
          if (_bookingController.discountMessage.value.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                _bookingController.discountMessage.value,
                style: TextStyle(
                  fontSize: 12,
                  color: _bookingController.isDiscountValid.value
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildNoteField() {
    return TextField(
      controller: _noteController,
      enabled: _state != _State.loading,
      maxLines: 2,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Ghi chú',
        labelStyle: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500),
        hintText: 'Nhập ghi chú cho chủ sân (nếu có)',
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        filled: true,
        fillColor: AppColors.secondary,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        prefixIcon:
            const Icon(Icons.note_outlined, size: 18, color: AppColors.primary),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap:
                _state == _State.loading ? null : () => Get.back(result: false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.inputBorder),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Hủy',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _state == _State.loading ? null : _onConfirm,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.buttonGradientStart,
                    AppColors.buttonGradientEnd
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: _state == _State.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Xác nhận',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

enum _State { idle, loading, success, error }
