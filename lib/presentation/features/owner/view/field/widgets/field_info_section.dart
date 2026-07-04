import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FieldInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descController;

  const FieldInfoSection({
    super.key,
    required this.nameController,
    required this.descController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Thông Tin Cơ Bản', Icons.info_outline),
        const SizedBox(height: 12),
        _buildTextField(
          controller: nameController,
          label: 'Tên sân',
          hint: 'VD: Sân bóng số 1',
          icon: Icons.sports_soccer,
          isRequired: true,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: descController,
          label: 'Mô tả',
          hint: 'Mô tả về sân bóng (không bắt buộc)',
          icon: Icons.description_outlined,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        labelStyle: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade400,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}
