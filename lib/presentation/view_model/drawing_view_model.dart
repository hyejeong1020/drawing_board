import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:drawing_board/utils/utils.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../view/component/drawing_painter.dart';

class DrawingViewModel extends ChangeNotifier {
  static const downloadMethodChannel = MethodChannel('com.download_manager');

  Color selectedColor = Colors.black;
  List<DrawingPoint?> stroke = [];
  List<DrawingPoint?> currentStroke = [];
  List<double> brushList = [1.0, 3.0, 5.0, 10.0, 15.0, 20.0];
  double strokeWidth = 5.0;
  bool isSelected = false;

  final ImagePicker imagePicker = ImagePicker();
  ui.Image? selectedImage;

  Future<void> onPanUpdate({required BuildContext context, required DragUpdateDetails details}) async {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset localPosition = renderBox.globalToLocal(details.globalPosition);

    if (localPosition.dy <= 550) {
      stroke.add(
        DrawingPoint(
          offset: renderBox.globalToLocal(details.globalPosition),
          color: isSelected ? Colors.white : selectedColor,
          strokeWidth: strokeWidth,
        ),
      );
      notifyListeners();
    }
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
    selectedImage = null;
    notifyListeners();
  }

  Future<void> drawingSelected() async {
    isSelected = !isSelected;
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

  Future<void> saveImage({required BuildContext context, required BoxConstraints constraints}) async {
    print('save image');
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder, Rect.fromPoints(Offset(0, 0), Offset(ssW(context), ssH(context))));

    if (selectedImage != null) {
      final paint = Paint();
      final src = Rect.fromLTWH(0, 0, selectedImage!.width.toDouble(), selectedImage!.height.toDouble());
      final dst = Rect.fromLTWH(0, 0, constraints.maxWidth, constraints.maxHeight);

      canvas.drawImageRect(selectedImage!, src, dst, paint);
    }

    for (int i = 0; i < stroke.length - 1; i++) {
      if (stroke[i] != null && stroke[i + 1] != null) {
        final paint = Paint()
          ..color = stroke[i]!.color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = stroke[i]!.strokeWidth;
        canvas.drawLine(stroke[i]!.offset, stroke[i + 1]!.offset, paint);
      }
    }

    final picture = pictureRecorder.endRecording();

    final image = await picture.toImage(ssW(context).toInt(), ssH(context).toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/drawing.png';
    final file = File(filePath);
    await file.writeAsBytes(buffer);

    try {
      await downloadMethodChannel.invokeListMethod('downloadFile', {'path': filePath});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이미지 다운로드 폴더 저장: $filePath')));
    } on PlatformException catch (e) {
      print("error: '${e.message}'.");
    }
  }

  Future<void> pickImage(ImageSource source) async {
    print('pick image');
    final pickerFile = await imagePicker.pickImage(source: source);

    if (pickerFile != null) {
      final file = File(pickerFile.path);
      final bytes = await file.readAsBytes();

      final image = await decodeImageFromList(bytes);
      selectedImage = image;
      notifyListeners();
    }
  }

}
