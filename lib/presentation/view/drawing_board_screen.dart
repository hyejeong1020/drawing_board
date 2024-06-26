import 'package:drawing_board/presentation/view/component/dialog_widget.dart';
import 'package:drawing_board/presentation/view/component/drawing_painter.dart';
import 'package:drawing_board/presentation/view_model/drawing_view_model.dart';
import 'package:drawing_board/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class DrawingBoardScreen extends StatefulWidget {
  const DrawingBoardScreen({super.key});

  @override
  State<DrawingBoardScreen> createState() => _DrawingBoardScreenState();
}

class _DrawingBoardScreenState extends State<DrawingBoardScreen> {
  final DrawingViewModel drawingViewModel = DrawingViewModel();
  final TextEditingController _hexInput = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
      drawingViewModel.addListener(updateScreen);
    });
  }

  void updateScreen() => setState(() {});

  void _openColorPicker({required BuildContext context}) {
    showDialogWidget(
      context: context,
      title: '색상 선택',
      content: SizedBox(
        width: ssW(context),
        height: ssH(context) * 0.4,
        child: Column(
          children: [
            ColorPicker(
              pickerColor: drawingViewModel.selectedColor,
              onColorChanged: drawingViewModel.onColorChanged,
              colorPickerWidth: 250,
              pickerAreaHeightPercent: 0.5,
              labelTypes: [],
              displayThumbColor: true,
              pickerAreaBorderRadius: BorderRadius.circular(5),
              hexInputController: _hexInput,
            ),
            CupertinoTextField(
              controller: _hexInput,
              decoration: BoxDecoration(color: Colors.blueGrey.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
              prefix: Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.tag)),
              suffix: IconButton(
                icon: Icon(Icons.content_paste_rounded),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: _hexInput.text));
                },
              ),
              maxLength: 9,
              inputFormatters: [
                UpperCaseTextFormatter(),
                FilteringTextInputFormatter.allow(RegExp(kValidHexPattern))
              ],
            ),
            12.sbH,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _selectedColorWidget(color: Colors.red),
                _selectedColorWidget(color: Colors.orange),
                _selectedColorWidget(color: Colors.yellow),
                _selectedColorWidget(color: Colors.green),
                _selectedColorWidget(color: Colors.blue),
                _selectedColorWidget(color: Colors.indigo),
                _selectedColorWidget(color: Colors.purple)
              ],
            )
          ],
        ),
      ),
    );
  }

  void _openThickness({required BuildContext context}) {
    showDialogWidget(
      context: context,
      title: '브러시 굵기 선택',
      content: SizedBox(
        width: ssW(context),
        height: ssH(context) * 0.22,
        child: ListView.builder(
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: drawingViewModel.brushList.length,
          itemBuilder: (context, index) => Column(
            children: [
              _selectedBrushWidget(
                context: context,
                height: drawingViewModel.brushList[index],
              ),
              10.sbH,
            ],
          ),
        ),
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
            IconButton(onPressed: drawingViewModel.saveImage, icon: Icon(Icons.save)),
            IconButton(onPressed: drawingViewModel.pickImage, icon: Icon(Icons.photo_library)),
            IconButton(onPressed: drawingViewModel.undo, icon: Icon(Icons.undo)),
            IconButton(onPressed: drawingViewModel.clearDrawing, icon: Icon(Icons.delete)),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) => GestureDetector(
            onPanUpdate: (details) => drawingViewModel.onPanUpdate(context: context, details: details),
            onPanEnd: (details) {
              drawingViewModel.stroke.add(null);
            },
            child: CustomPaint(
              painter: DrawingPainter(strokes: drawingViewModel.stroke, isErasing: drawingViewModel.isErasing),
              size: Size(constraints.maxWidth, constraints.maxHeight),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          height: 65,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _openThickness(context: context),
                child: drawingViewModel.isBrush
                    ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueGrey.withOpacity(0.1),
                        ),
                        child: Icon(Icons.brush),
                        width: 50,
                        height: 50,
                      )
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.brush),
                        width: 50,
                        height: 50,
                      ),
              ),
              10.sbW,
              GestureDetector(
                onTap: drawingViewModel.eraserDrawing,
                child: drawingViewModel.isErasing
                    ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueGrey.withOpacity(0.1),
                        ),
                        child: Icon(Icons.how_to_vote),
                        width: 50,
                        height: 50,
                      )
                    : Container(
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: Icon(Icons.how_to_vote),
                        width: 50,
                        height: 50,
                      ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () => _openColorPicker(context: context),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.palette, color: drawingViewModel.selectedColor,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectedColorWidget({required Color color}) {
    return GestureDetector(
      onTap: () => drawingViewModel.onColorChanged(color),
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color
        ),
      ),
    );
  }

  Widget _selectedBrushWidget({required BuildContext context, required double height}) {
    return GestureDetector(
      onTap: () => drawingViewModel.onThicknessChanged(height),
      child: SizedBox(
        width: ssW(context),
        height: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              height.toString(),
              style: textTheme(context).bodyMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
            Container(
              width: ssW(context) * 0.55,
              height: height,
              color: drawingViewModel.selectedColor,
            )
          ],
        )
      ),
    );
  }
}
