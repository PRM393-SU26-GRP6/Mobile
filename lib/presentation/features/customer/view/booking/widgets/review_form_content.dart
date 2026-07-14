import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/review_form_controller.dart';
import 'package:flutter/material.dart';

class ReviewFormContent extends StatelessWidget {
  const ReviewFormContent({
    required this.controller,
    required this.formKey,
    required this.onCancel,
    required this.onSubmit,
    super.key,
  });

  final ReviewFormController controller;
  final GlobalKey<FormState> formKey;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  controller.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Đóng',
                onPressed: controller.isSubmitting ? null : onCancel,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Text(
            'Sân: ${controller.venueName}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          const Text(
            'Đánh giá của bạn',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            children: List.generate(5, (index) {
              final value = index + 1;
              return IconButton(
                tooltip: '$value sao',
                onPressed: () => controller.selectRating(value),
                iconSize: 36,
                icon: Icon(
                  value <= controller.rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: value <= controller.rating
                      ? Colors.amber
                      : Colors.grey.shade400,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.commentController,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              labelText: 'Nhận xét',
              hintText: controller.isEdit
                  ? 'Cập nhật nhận xét của bạn...'
                  : 'Chia sẻ cảm nhận của bạn...',
            ),
            validator: (value) {
              final text = (value ?? '').trim();
              if (text.isEmpty) return 'Vui lòng nhập nhận xét.';
              if (text.length < 5) return 'Nhận xét phải có ít nhất 5 ký tự.';
              return null;
            },
          ),
          if (controller.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              controller.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.isSubmitting ? null : onCancel,
                  child: const Text('Hủy'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: controller.isSubmitting ? null : onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: controller.isSubmitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(controller.submitLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
