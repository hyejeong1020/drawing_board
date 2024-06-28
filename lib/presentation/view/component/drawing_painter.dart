import 'package:drawing_board/utils/utils.dart';
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
  final ui.Image? selectedImage;

  DrawingPainter(this.selectedImage, {super.repaint, required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    if (selectedImage != null) {
      paintImage(canvas: canvas, rect: Rect.fromLTWH(0, 0, size.width, size.height), image: selectedImage!);
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