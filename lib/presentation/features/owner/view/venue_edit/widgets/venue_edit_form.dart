import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/venue_edit_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VenueEditForm extends StatelessWidget {
  const VenueEditForm({
    super.key,
    required this.controller,
    required this.onSave,
  });

  final VenueEditController controller;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return Obx(() => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _VenueInput(
                controller: controller.nameController,
                label: 'Ten venue',
                icon: Icons.stadium_outlined,
              ),
              _VenueInput(
                controller: controller.addressController,
                label: 'Dia chi',
                icon: Icons.location_on_outlined,
                maxLines: 2,
              ),
              _VenueInput(
                controller: controller.phoneController,
                label: 'So dien thoai',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              _VenueInput(
                controller: controller.openingHoursController,
                label: 'Gio mo cua',
                icon: Icons.schedule_outlined,
              ),
              _VenueInput(
                controller: controller.descriptionController,
                label: 'Mo ta',
                icon: Icons.description_outlined,
                maxLines: 4,
              ),
              if (controller.errorMessage.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: controller.isSaving.value ? null : onSave,
                  icon: controller.isSaving.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Luu thay doi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class _VenueInput extends StatelessWidget {
  const _VenueInput({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
