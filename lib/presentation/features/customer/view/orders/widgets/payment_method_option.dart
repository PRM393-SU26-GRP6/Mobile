import 'package:exe101/domain/models/payment_model.dart';
import 'package:flutter/material.dart';

class PaymentMethodOption {
  final PaymentMethod method;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const PaymentMethodOption({
    required this.method,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}
