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
  final bool isErasing;
  // final ui.Image? backgroundImage;

  DrawingPainter({super.repaint, required this.strokes, required this.isErasing});

  @override
  void paint(Canvas canvas, Size size) {
    // if (backgroundImage != null) {
    //   canvas.drawImage(backgroundImage!, Offset.zero, Paint());
    // }

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