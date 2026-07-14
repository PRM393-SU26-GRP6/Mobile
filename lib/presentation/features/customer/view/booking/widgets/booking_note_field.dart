import 'package:exe101/presentation/features/customer/controller/booking_confirmation_controller.dart';
import 'package:flutter/material.dart';

class BookingNoteField extends StatelessWidget {
  const BookingNoteField({required this.controller, super.key});

  final BookingConfirmationController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.noteTextController,
      enabled: !controller.isLoading,
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: 'Ghi chú',
        hintText: 'Nhập ghi chú cho chủ sân (nếu có)',
        prefixIcon: Icon(Icons.note_outlined),
      ),
    );
  }
}
