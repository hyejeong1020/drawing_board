import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'dart:io';

class DrawingRemover extends StatefulWidget {
  @override
  _DrawingRemoverState createState() => _DrawingRemoverState();
}

class _DrawingRemoverState extends State<DrawingRemover> {
  List<List<Offset?>> strokes = [];
  List<Offset?> currentStroke = [];

  void saveDrawing() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (var stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        if (stroke[i] != null && stroke[i + 1] != null) {
          canvas.drawLine(stroke[i]!, stroke[i + 1]!, paint);
        }
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
      strokes.clear();
    });
  }

  void undo() {
    setState(() {
      if (strokes.isNotEmpty) {
        strokes.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drawing App'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveDrawing,
          ),
          IconButton(
            icon: Icon(Icons.undo),
            onPressed: undo,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: clearDrawing,
          ),
        ],
      ),
      body: GestureDetector(
        onPanStart: (details) {
          setState(() {
            currentStroke = [];
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            currentStroke.add(renderBox.globalToLocal(details.globalPosition));
          });
        },
        onPanUpdate: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            currentStroke.add(renderBox.globalToLocal(details.globalPosition));
          });
        },
        onPanEnd: (details) {
          setState(() {
            strokes.add(currentStroke);
            currentStroke = [];
          });
        },
        child: CustomPaint(
          painter: DrawingPainter(strokes),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<List<Offset?>> strokes;

  DrawingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (var stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        if (stroke[i] != null && stroke[i + 1] != null) {
          canvas.drawLine(stroke[i]!, stroke[i + 1]!, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}


class DrawingPoint {
  final Offset offset;
  final Color color;
  final double strokeWidth;

  DrawingPoint({
    required this.offset,
    required this.color,
    required this.strokeWidth,
  });
}

class DrawingPage2 extends StatefulWidget {
  const DrawingPage2({super.key});

  @override
  _DrawingPage2State createState() => _DrawingPage2State();
}

class _DrawingPage2State extends State<DrawingPage2> {
  List<DrawingPoint?> points = [];
  List<DrawingPoint?> undoStack = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 5.0;
  ui.Image? backgroundImage;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Drawing App'),
          actions: [
            IconButton(
              icon: Icon(Icons.undo),
              onPressed: _undo,
            ),
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
                painter: DrawingPainter2(points, backgroundImage),
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
                      decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle
                      ),
                    ),
                    SizedBox(width: 15),
                    Text('색상 선택', style: Theme.of(context).textTheme.bodyMedium),
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

  void _undo() {
    setState(() {
      if (points.isNotEmpty) {
        undoStack.add(points.removeLast());
        while (points.isNotEmpty && points.last != null) {
          undoStack.add(points.removeLast());
        }
        if (points.isNotEmpty) {
          undoStack.add(points.removeLast());
        }
      }
    });
  }

  void _openColorPicker(BuildContext context) {
    // 색상 선택 로직을 구현하세요.
  }
}

class DrawingPainter2 extends CustomPainter {
  final List<DrawingPoint?> points;
  final ui.Image? backgroundImage;

  DrawingPainter2(this.points, this.backgroundImage);

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
