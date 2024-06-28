import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class DrawingPoint {
  final Offset offset;
  final Color color;
  final double strokeWidth;

  DrawingPoint({required this.offset, required this.color, required this.strokeWidth});
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> strokes;
  final ui.Image? backgroundImage;
  final BoxConstraints constraints;
  final double canvasHeight;

  DrawingPainter(this.backgroundImage, {super.repaint, required this.strokes, required this.constraints, required this.canvasHeight});

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundImage != null) {
      final paint = Paint();
      final src = Rect.fromLTWH(0, 0, backgroundImage!.width.toDouble(), backgroundImage!.height.toDouble());
      final dst = Rect.fromLTWH(0, 0, constraints.maxWidth, canvasHeight);

      canvas.drawImageRect(backgroundImage!, src, dst, paint);
    }

    for (int i = 0; i < strokes.length - 1; i++) {
      if (strokes[i] != null && strokes[i + 1] != null) {
        final paint = Paint()
          ..color = strokes[i]!.color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokes[i]!.strokeWidth;
        canvas.drawLine(strokes[i]!.offset, strokes[i + 1]!.offset, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}