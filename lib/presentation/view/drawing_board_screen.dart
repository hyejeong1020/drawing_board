import 'package:drawing_board/presentation/view/component/drawing_painter.dart';
import 'package:drawing_board/presentation/view_model/drawing_view_model.dart';
import 'package:drawing_board/utils/utils.dart';
import 'package:flutter/material.dart';

class DrawingBoardScreen extends StatefulWidget {
  const DrawingBoardScreen({super.key});

  @override
  State<DrawingBoardScreen> createState() => _DrawingBoardScreenState();
}

class _DrawingBoardScreenState extends State<DrawingBoardScreen> {
  final DrawingViewModel drawingViewModel = DrawingViewModel();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
      drawingViewModel.addListener(updateScreen);
    });
  }

  void updateScreen() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('그림판', style: textTheme(context).bodyLarge),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.save)),
            IconButton(onPressed: () {}, icon: Icon(Icons.photo_library)),
            IconButton(onPressed: () {}, icon: Icon(Icons.undo)),
            IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) => GestureDetector(
            onPanUpdate: (details) => drawingViewModel.onPanUpdate(context: context, details: details),
            onPanEnd: (details) {
              drawingViewModel.stroke.add(null);
            },
            child: CustomPaint(
              painter: DrawingPainter(strokes: drawingViewModel.stroke),
              size: Size(constraints.maxWidth, constraints.maxHeight),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: drawingViewModel.selectedColor
                        ),
                      ),
                      15.sbW,
                      Text('색상 선택', style: textTheme(context).bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
