import 'dart:ui' as ui;

import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Simple bar chart vẽ bằng CustomPainter.
/// Tránh thêm dependency chart ngoài (fl_chart/syncfusion).
class SimpleBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const SimpleBarChart({
    super.key,
    required this.values,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 180),
      painter: _BarChartPainter(values: values, labels: labels),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;

  _BarChartPainter({required this.values, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final safeMax = maxVal <= 0 ? 1.0 : maxVal;

    const reservedTop = 10.0;
    const reservedBottom = 24.0;
    final chartHeight = size.height - reservedTop - reservedBottom;
    final barWidth = (size.width / values.length).clamp(8.0, 32.0) * 0.6;

    final barPaint = Paint()..color = AppColors.primary;
    final bgPaint = Paint()..color = AppColors.primary.withValues(alpha: 0.1);
    final axisPaint = Paint()
      ..color = AppColors.inputBorder
      ..strokeWidth = 1;
    final textStyle = const TextStyle(
      fontSize: 10,
      color: AppColors.textSecondary,
    );

    canvas.drawLine(
      Offset(0, size.height - reservedBottom),
      Offset(size.width, size.height - reservedBottom),
      axisPaint,
    );

    for (int i = 0; i < values.length; i++) {
      final x = (size.width / values.length) * i +
          (size.width / values.length - barWidth) / 2;
      final h = (values[i] / safeMax) * chartHeight;
      final rect = Rect.fromLTWH(
        x,
        size.height - reservedBottom - h,
        barWidth,
        h,
      );

      final bgRect = Rect.fromLTWH(
        x,
        size.height - reservedBottom - chartHeight,
        barWidth,
        chartHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
        bgPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        barPaint,
      );

      if (i < labels.length && labels[i].isNotEmpty) {
        final tp = TextPainter(
          text: TextSpan(text: labels[i], style: textStyle),
          textDirection: ui.TextDirection.ltr,
        )..layout(maxWidth: 40);
        tp.paint(
          canvas,
          Offset(
            x + barWidth / 2 - tp.width / 2,
            size.height - reservedBottom + 4,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.values != values || old.labels != labels;
}
