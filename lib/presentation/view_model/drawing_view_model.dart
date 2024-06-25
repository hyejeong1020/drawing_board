import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../view/component/drawing_painter.dart';

class DrawingViewModel extends ChangeNotifier {
  Color selectedColor = Colors.black;
  List<DrawingPoint?> stroke = [];
  List<DrawingPoint?> currentStroke = [];
  double strokeWidth = 5.0;

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

  Future<void> saveImage() async {}

  Future<void> pickImage() async {}

  Future<void> undo() async {
    if (stroke.isNotEmpty) {
      currentStroke.add(stroke.removeLast());
      while (stroke.isNotEmpty && stroke.last != null) {
        currentStroke.add(stroke.removeLast());
      }
      if (stroke.isNotEmpty) {
        currentStroke.add(stroke.removeLast());
      }
      //        while (points.isNotEmpty && points.last != null) {
      //           undoStack.add(points.removeLast());
      //         }
      //         if (points.isNotEmpty) {
      //           undoStack.add(points.removeLast());
      //         }
    }
  }

  Future<void> clearDrawing() async {}
}
