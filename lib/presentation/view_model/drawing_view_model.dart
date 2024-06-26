import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../view/component/drawing_painter.dart';

class DrawingViewModel extends ChangeNotifier {
  Color selectedColor = Colors.black;
  List<DrawingPoint?> stroke = [];
  List<DrawingPoint?> currentStroke = [];
  List<double> brushList = [1.0, 3.0, 5.0, 10.0, 15.0, 20.0];
  double strokeWidth = 5.0;
  bool isErasing = false;
  bool isBrush = true;

  Future<void> onPanUpdate({required BuildContext context, required DragUpdateDetails details}) async {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    stroke.add(
      DrawingPoint(
        offset: renderBox.globalToLocal(details.globalPosition),
        color: selectedColor,
        strokeWidth: strokeWidth,
      ),
    );
    notifyListeners();
  }

  Future<void> undo() async {
    if (stroke.isNotEmpty) {
      currentStroke.add(stroke.removeLast());
      while (stroke.isNotEmpty && stroke.last != null) {
        currentStroke.add(stroke.removeLast());
      }
      if (stroke.isNotEmpty) {
        currentStroke.add(stroke.removeLast());
      }
    }
  }

  Future<void> clearDrawing() async {
    stroke.clear();
    notifyListeners();
  }

  Future<void> eraserDrawing() async {
    isBrush = !isBrush;
    isErasing = !isErasing;
    notifyListeners();
  }

  Future<void> onColorChanged(Color color) async {
    selectedColor = color;
    notifyListeners();
  }

  Future<void> onThicknessChanged(double value) async {
    strokeWidth = value;
    notifyListeners();
  }

  Future<void> saveImage() async {}

  Future<void> pickImage() async {}

}
