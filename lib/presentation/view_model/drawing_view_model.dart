import 'dart:io';
import 'dart:ui' as ui;

import 'package:drawing_board/presentation/view/component/widget/dialog_widget.dart';
import 'package:flutter/foundation.dart';
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
  double canvasHeight = 600;
  GlobalKey globalKey = GlobalKey();

  final ImagePicker imagePicker = ImagePicker();
  ui.Image? selectedImage;

  Future<void> onPanUpdate({required BuildContext context, required DragUpdateDetails details}) async {
    RenderBox renderBox = context.findRenderObject() as RenderBox;

    stroke.add(
      DrawingPoint(
        offset: renderBox.globalToLocal(details.globalPosition),
        color: isSelected ? Colors.white : selectedColor,
        strokeWidth: strokeWidth,
      ),
    );
    notifyListeners();
  }

  Future<void> undo() async {
    print('undo');
    if (stroke.isNotEmpty) {
      currentStroke.add(stroke.removeLast());

      while (stroke.isNotEmpty && stroke.last != null) {
        currentStroke.add(stroke.removeLast());
      }

      if (stroke.isNotEmpty) {
        currentStroke.add(stroke.removeLast());
      }
    }
    notifyListeners();
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

  Future<void> saveImage({required BuildContext context}) async {
    print('save image');

    try {
      RenderRepaintBoundary renderRepaintBoundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await renderRepaintBoundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/drawing.png';
      final file = File(filePath);
      await file.writeAsBytes(buffer);

      await downloadMethodChannel.invokeListMethod('downloadFile', {'path': filePath});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이미지 다운로드 폴더 저장')));
    } catch (e) {
      print(e);
      showDialogWidget(context: context, title: '이미지 저장에 실패했습니다', content: null);
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