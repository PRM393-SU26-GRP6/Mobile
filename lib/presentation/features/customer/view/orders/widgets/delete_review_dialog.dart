import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> showDeleteReviewDialog() async {
  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8),
          Text('Xóa đánh giá?'),
        ],
      ),
      content: const Text(
        'Bạn có chắc chắn muốn xóa đánh giá này? Sau khi xóa, bạn có thể tạo lại đánh giá mới.',
        style: TextStyle(fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back<bool>(result: false),
          child: const Text('Hủy'),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.red.shade600,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextButton(
            onPressed: () => Get.back<bool>(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Xóa',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    ),
    barrierDismissible: true,
  );
  return confirmed ?? false;
}
