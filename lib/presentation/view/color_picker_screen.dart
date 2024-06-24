import 'package:drawing_board/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerScreen extends StatefulWidget {
  @override
  _ColorPickerScreenState createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  Color selectedColor = Colors.blue;
  final TextEditingController _textEditingController = TextEditingController();

  void changeColor(Color color) {
    setState(() {
      selectedColor = color;
    });
  }

  void _openColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('색상 선택', style: textTheme(context).bodyMedium,),
          content: SingleChildScrollView(
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
                  pickerAreaBorderRadius: BorderRadius.only(
                    topLeft: Radius.circular(2),
                    topRight: Radius.circular(2)
                  ),
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
                  decoration: BoxDecoration(
                    color: Color(0xfff1f3f5)
                  ),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                color: selectedColor,
              ),
              20.sbH,
              ElevatedButton(
                onPressed: () => _openColorPicker(context),
                child: Text('색상 선택'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ColorPickerExample extends StatefulWidget {
  @override
  _ColorPickerExampleState createState() => _ColorPickerExampleState();
}

class _ColorPickerExampleState extends State<ColorPickerExample> {
  Color selectedColor = Colors.blue;

  void _openColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('색상 선택'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  selectedColor = color;
                });
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              color: selectedColor,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _openColorPicker(context),
              child: Text('색상 선택'),
            ),
          ],
        ),
      ),
    );
  }
}

class BlockPicker extends StatelessWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  BlockPicker({
    required this.pickerColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        _buildColorBlock(Colors.red),
        _buildColorBlock(Colors.green),
        _buildColorBlock(Colors.blue),
        _buildColorBlock(Colors.yellow),
        _buildColorBlock(Colors.orange),
        _buildColorBlock(Colors.purple),
        // 원하는 색상을 추가하세요.
      ],
    );
  }

  Widget _buildColorBlock(Color color) {
    return GestureDetector(
      onTap: () => onColorChanged(color),
      child: Container(
        margin: EdgeInsets.all(4.0),
        width: 50,
        height: 50,
        color: color,
      ),
    );
  }
}
