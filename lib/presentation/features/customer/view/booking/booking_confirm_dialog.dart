import 'package:dio/dio.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';
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

  @override
  void dispose() {
    _discountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    final discountCode = _discountController.text.trim();
    final note = _noteController.text.trim();

    setState(() {
      _state = _State.loading;
      _errorMessage = '';
    });

    try {
      final bookingController = Get.find<BookingController>();
      await bookingController.createBooking(
        slotIds: widget.slotIds,
        discountCode: discountCode.isEmpty ? '' : discountCode,
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
          msg = 'Dữ liệu không hợp lệ${serverMsg.isNotEmpty ? ': $serverMsg' : ''}';
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
      backgroundColor: AppColors.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_state == _State.success) ...[
              _buildSuccess(),
            ] else ...[
              _buildHeader(),
              const SizedBox(height: 20),
              _buildInfo(),
              const SizedBox(height: 20),
              _buildDiscountField(),
              const SizedBox(height: 16),
              _buildNoteField(),
              const SizedBox(height: 8),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
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
        const Icon(Icons.calendar_month, color: AppColors.accent, size: 28),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Xác nhận đặt sân',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (_state != _State.loading)
          GestureDetector(
            onTap: () => Get.back(result: false),
            child: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
      ],
    );
  }

  Widget _buildInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _infoRow('Sân', widget.fieldName),
          const SizedBox(height: 6),
          _infoRow('Địa điểm', widget.venueName),
          const SizedBox(height: 6),
          _infoRow('Số khung giờ', '${widget.slotCount}'),
          const SizedBox(height: 6),
          _infoRow('Tổng tiền', '${widget.totalPrice.toStringAsFixed(0)}đ',
              isBold: true),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? AppColors.accent : AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountField() {
    return TextField(
      controller: _discountController,
      enabled: _state != _State.loading,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Mã giảm giá (không bắt buộc)',
        labelStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        hintText: 'Nhập mã (nếu có)',
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        filled: true,
        fillColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        prefixIcon: const Icon(Icons.discount_outlined,
            size: 20, color: AppColors.textSecondary),
      ),
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
        labelStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        hintText: 'Nhập ghi chú (nếu có)',
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        filled: true,
        fillColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        prefixIcon:
            const Icon(Icons.note_outlined, size: 20, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _state == _State.loading ? null : () => Get.back(result: false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Center(
                child: Text(
                  'Hủy',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _state == _State.loading
                        ? Colors.grey.shade600
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _state == _State.loading ? null : _onConfirm,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
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
                        'Đặt sân',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return SizedBox(
      width: 280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 40,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Đặt sân thành công',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Đơn đặt sân của bạn đang chờ chủ sân duyệt. Vui lòng kiểm tra trong phần Đơn hàng.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => Get.back(result: true),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Đã hiểu',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

enum _State { idle, loading, success, error }
