import 'dart:ui' as ui;
import 'package:drawing_board/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DrawingPage extends StatefulWidget {
  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  List<DrawingPoint?> points = [];
  double strokeWidth = 5.0;
  ui.Image? backgroundImage;
  Color selectedColor = Colors.black;
  final TextEditingController _textEditingController = TextEditingController();

  void changeColor(Color color) {
    setState(() {
      selectedColor = color;
    });
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final bytes = await file.readAsBytes();
      final image = await decodeImageFromList(bytes);
      setState(() {
        backgroundImage = image;
      });
    }
  }

  Future<void> saveImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromPoints(Offset(0, 0), Offset(400, 600)));

    if (backgroundImage != null) {
      canvas.drawImage(backgroundImage!, Offset.zero, Paint());
    }

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        final paint = Paint()
          ..color = points[i]!.color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = points[i]!.strokeWidth;
        canvas.drawLine(points[i]!.offset, points[i + 1]!.offset, paint);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(400, 600);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/drawing.png';
    final file = File(filePath);
    await file.writeAsBytes(buffer);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('그림이 저장되었습니다: $filePath')));
  }

  void clearDrawing() {
    setState(() {
      points.clear();
    });
  }

  void undo() {
    setState(() {
      if (points.isNotEmpty) {
        points.removeLast();
      }
    });
  }

  void _openColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('색상 선택', style: textTheme(context).bodyMedium,),
        content: SizedBox(
          width: ssW(context),
          height: ssH(context) * 0.48,
          child: Column(
            children: [
              ColorPicker(
                pickerColor: selectedColor,
                onColorChanged: changeColor,
                colorPickerWidth: 300,
                pickerAreaHeightPercent: 0.7,
                enableAlpha: true,
                displayThumbColor: true,
                paletteType: PaletteType.hsvWithHue,
                labelTypes: [],
                pickerAreaBorderRadius: BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(2)),
                hexInputController: _textEditingController,
                portraitOnly: true,
              ),
              CupertinoTextField(
                controller: _textEditingController,
                prefix: Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.tag),),
                suffix: IconButton(
                  icon: Icon(Icons.content_paste_rounded),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: _textEditingController.text));
                  },
                ),
                maxLength: 9,
                decoration: BoxDecoration(color: Color(0xfff1f3f5)),
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  FilteringTextInputFormatter.allow(RegExp(kValidHexPattern))
                ],
              )
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('완료'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('그림판', style: textTheme(context).bodyLarge),
          actions: [
            IconButton(icon: Icon(Icons.save), onPressed: saveImage),
            IconButton(icon: Icon(Icons.photo_library), onPressed: pickImage),
            IconButton(onPressed: undo, icon: Icon(Icons.undo)),
            IconButton(onPressed: clearDrawing, icon: Icon(Icons.delete)),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onPanUpdate: (details) {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                setState(() {
                  points.add(
                    DrawingPoint(
                      offset: renderBox.globalToLocal(details.globalPosition),
                      color: selectedColor,
                      strokeWidth: strokeWidth,
                    ),
                  );
                });
              },
              onPanEnd: (details) {
                points.add(null);
              },
              child: CustomPaint(
                painter: DrawingPainter(points, backgroundImage),
                size: Size(constraints.maxWidth, constraints.maxHeight),
              ),
            );
          },
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => _openColorPicker(context),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      color: selectedColor,
                    ),
                    15.sbW,
                    Text('색상 선택', style: textTheme(context).bodySmall),
                  ],
                ),
              ),
              Slider(
                min: 1.0,
                max: 10.0,
                value: strokeWidth,
                onChanged: (value) {
                  setState(() {
                    strokeWidth = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawingPoint {
  final Offset offset;
  final Color color;
  final double strokeWidth;

  DrawingPoint({required this.offset, required this.color, required this.strokeWidth});
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> points;
  final ui.Image? backgroundImage;

  DrawingPainter(this.points, this.backgroundImage);

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundImage != null) {
      canvas.drawImage(backgroundImage!, Offset.zero, Paint());
    }

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        final paint = Paint()
          ..color = points[i]!.color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = points[i]!.strokeWidth;
        canvas.drawLine(points[i]!.offset, points[i + 1]!.offset, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ColorPickerButton extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  ColorPickerButton({required this.selectedColor, required this.onColorSelected});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Color>(
      value: selectedColor,
      items: [
        DropdownMenuItem(
          value: Colors.black,
          child: Container(
            width: 24,
            height: 24,
            color: Colors.black,
          ),
        ),
        DropdownMenuItem(
          value: Colors.red,
          child: Container(
            width: 24,
            height: 24,
            color: Colors.red,
          ),
        ),
        DropdownMenuItem(
          value: Colors.green,
          child: Container(
            width: 24,
            height: 24,
            color: Colors.green,
          ),
        ),
        DropdownMenuItem(
          value: Colors.blue,
          child: Container(
            width: 24,
            height: 24,
            color: Colors.blue,
          ),
        ),
      ],
      onChanged: (color) {
        onColorSelected(color!);
      },
    );
  }
}
