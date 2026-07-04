import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/domain/models/review_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ReviewFormMode { create, edit }

class ReviewFormDialog extends StatefulWidget {
  final BookingDto booking;
  final ReviewFormMode mode;
  final ReviewModel? existing;

  const ReviewFormDialog({
    super.key,
    required this.booking,
    this.mode = ReviewFormMode.create,
    this.existing,
  });

  static Future<bool> showCreate(BookingDto booking) async {
    final result = await Get.dialog<bool>(
      ReviewFormDialog(booking: booking, mode: ReviewFormMode.create),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  static Future<bool> showEdit(BookingDto booking, ReviewModel existing) async {
    final result = await Get.dialog<bool>(
      ReviewFormDialog(
        booking: booking,
        mode: ReviewFormMode.edit,
        existing: existing,
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  @override
  State<ReviewFormDialog> createState() => _ReviewFormDialogState();
}

class _ReviewFormDialogState extends State<ReviewFormDialog> {
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late int _rating;
  String? _errorMessage;
  bool _submitting = false;

  bool get _isEdit => widget.mode == ReviewFormMode.edit;

  @override
  void initState() {
    super.initState();
    if (_isEdit && widget.existing != null) {
      _rating = widget.existing!.rating.clamp(1, 5);
      _commentController.text = widget.existing!.comment ?? '';
    } else {
      _rating = 0;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String get _venueId {
    if (widget.booking.items != null && widget.booking.items!.isNotEmpty) {
      return widget.booking.items!.first.venueId;
    }
    return widget.booking.fieldId;
  }

  String get _venueName {
    if (widget.booking.items != null && widget.booking.items!.isNotEmpty) {
      return widget.booking.items!.first.venueName ?? 'Sân';
    }
    return 'Sân';
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rating == 0) {
      setState(() => _errorMessage = 'Vui lòng chọn số sao');
      return;
    }

    setState(() {
      _errorMessage = null;
      _submitting = true;
    });

    try {
      final apiService = Get.find<ApiServiceImpl>();

      if (_isEdit && widget.existing != null) {
        final updated = await apiService.updateReview(
          reviewId: widget.existing!.reviewId,
          rating: _rating,
          comment: _commentController.text.trim(),
        );
        if (!mounted) return;
        Get.back<bool>(result: true);
        Get.snackbar(
          'Thành công',
          'Đã cập nhật đánh giá',
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
        );
        return _handleSuccess(updated);
      }

      final created = await apiService.createReview(
        venueId: _venueId,
        bookingId: widget.booking.id,
        rating: _rating,
        comment: _commentController.text.trim(),
      );
      if (!mounted) return;
      Get.back<bool>(result: true);
      Get.snackbar(
        'Thành công',
        'Cảm ơn bạn đã đánh giá sân',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
      );
      _handleSuccess(created);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _friendly(e.toString());
        _submitting = false;
      });
    }
  }

  void _handleSuccess(ReviewModel _) {
    // Cache được cập nhật từ caller (orders_page) sau khi dialog đóng
  }

  String _friendly(String raw) {
    if (raw.contains('400')) {
      return _isEdit
          ? 'Dữ liệu cập nhật không hợp lệ'
          : 'Bạn đã đánh giá booking này rồi hoặc dữ liệu không hợp lệ';
    }
    if (raw.contains('401')) return 'Phiên đăng nhập hết hạn';
    if (raw.contains('404')) return 'Không tìm thấy review hoặc booking';
    return raw.replaceFirst('Exception: ', '');
  }

  String get _title => _isEdit ? 'Chỉnh sửa đánh giá' : 'Đánh giá sân';

  String get _submitLabel => _isEdit ? 'Cập nhật' : 'Gửi đánh giá';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back<bool>(result: false),
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Sân: $_venueName',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Đánh giá của bạn',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStarRow(),
                const SizedBox(height: 20),
                const Text(
                  'Nhận xét',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _commentController,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: _isEdit
                        ? 'Cập nhật nhận xét của bạn...'
                        : 'Chia sẻ cảm nhận của bạn...',
                    filled: true,
                    fillColor: AppColors.secondary,
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
                      borderSide: const BorderSide(color: AppColors.accent),
                    ),
                    counterStyle: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) return 'Vui lòng nhập nhận xét';
                    if (text.length < 5) return 'Nhận xét quá ngắn (tối thiểu 5 ký tự)';
                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, size: 16, color: Colors.red.shade700),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _submitting
                            ? null
                            : () => Get.back<bool>(result: false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.inputBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Hủy',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.buttonGradientStart,
                              AppColors.buttonGradientEnd,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _onSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _submitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _submitLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStarRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (i) {
        final value = i + 1;
        final isActive = value <= _rating;
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => setState(() {
              _rating = _rating == value ? 0 : value;
              if (_errorMessage != null) _errorMessage = null;
            }),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                isActive ? Icons.star_rounded : Icons.star_border_rounded,
                size: 36,
                color: isActive ? Colors.amber : Colors.grey.shade400,
              ),
            ),
          ),
        );
      }),
    );
  }
}