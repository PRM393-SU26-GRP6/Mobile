import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PricingSection extends StatelessWidget {
  final TextEditingController morningController;
  final TextEditingController afternoonController;
  final TextEditingController eveningController;

  const PricingSection({
    super.key,
    required this.morningController,
    required this.afternoonController,
    required this.eveningController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Bảng Giá (VNĐ/giờ)', Icons.attach_money),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Column(
            children: [
              _buildPriceRow(
                icon: Icons.wb_sunny_outlined,
                label: 'Sáng',
                time: '06:00 - 12:00',
                controller: morningController,
                color: Colors.orange,
              ),
              const Divider(height: 24, color: AppColors.inputBorder),
              _buildPriceRow(
                icon: Icons.wb_cloudy_outlined,
                label: 'Chiều',
                time: '12:00 - 18:00',
                controller: afternoonController,
                color: Colors.blue,
              ),
              const Divider(height: 24, color: AppColors.inputBorder),
              _buildPriceRow(
                icon: Icons.nights_stay_outlined,
                label: 'Tối',
                time: '18:00 - 22:00',
                controller: eveningController,
                color: Colors.indigo,
              ),
            ],
          ),
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

  Widget _buildPriceRow({
    required IconData icon,
    required String label,
    required String time,
    required TextEditingController controller,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 120,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
              filled: true,
              fillColor: AppColors.secondary,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              suffixText: 'đ',
              suffixStyle: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
