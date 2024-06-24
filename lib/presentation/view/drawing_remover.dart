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
