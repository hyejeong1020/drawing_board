import 'package:drawing_board/presentation/view_model/drawing_view_model.dart';
import 'package:drawing_board/utils/utils.dart';
import 'package:flutter/material.dart';

class DrawingBoardScreen extends StatefulWidget {
  final DrawingViewModel drawingViewModel;

  const DrawingBoardScreen({super.key, required this.drawingViewModel});

  @override
  State<DrawingBoardScreen> createState() => _DrawingBoardScreenState();
}

class _DrawingBoardScreenState extends State<DrawingBoardScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
      widget.drawingViewModel.addListener(updateScreen);
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
            onPanUpdate: (details) {

            },
            onPanEnd: (details) {

            },
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
                          color: widget.drawingViewModel.selectedColor
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
