import 'dart:io';

import 'package:drawing_board/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageDownloadExampleScreen extends StatefulWidget {
  const ImageDownloadExampleScreen({super.key});

  @override
  State<ImageDownloadExampleScreen> createState() => _ImageDownloadExampleScreenState();
}

class _ImageDownloadExampleScreenState extends State<ImageDownloadExampleScreen> {
  static const downloadChannel = MethodChannel('com.download_manager');

  final ImagePicker imagePicker = ImagePicker();
  File? selectedImages;

  Future<void> pickImage(ImageSource imagesSource) async {
    final pickerFile = await imagePicker.pickImage(source: imagesSource);

    if (pickerFile != null) {
      setState(() {
        selectedImages =  File(pickerFile.path);
      });
    }
  }

  Future<void> imageDownload({required BuildContext context}) async {
    if (selectedImages == null) return;

    final Directory directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/downloadFile.png';
    final file = File(filePath);

    await file.writeAsBytes(await selectedImages!.readAsBytes());

    try {
      await downloadChannel.invokeListMethod('downloadFile', {'path': filePath});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이미지 다운로드 폴더 저장: $filePath')));
    } on PlatformException catch (e) {
      print("Failed to Invoke: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: ssW(context),
          height: ssH(context),
          child: Column(
            children: [
              Spacer(),
              10.sbH,
              Container(
                width: 300,
                height: 300,
                color: Colors.blueGrey.withOpacity(0.1),
                child: selectedImages == null ? null : Image.file(selectedImages!),
              ),
              10.sbH,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  textBtn(context: context, text: '이미지 가져오기', onPressed: () => pickImage(ImageSource.gallery),),
                  10.sbW,
                  textBtn(context: context, text: '이미지 다운로드', onPressed: () => imageDownload(context: context),),
                ],
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget textBtn({required BuildContext context, required String text, required void Function() onPressed}) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: textTheme(context).bodyMedium!.copyWith(color: Colors.white),
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.blue),
        shape: WidgetStatePropertyAll(BeveledRectangleBorder(borderRadius: BorderRadius.circular(0)))
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Offset position = Offset(100, 100); // 초기 위치
  double imageWidth = 100;
  double imageHeight = 100;
  File? _image;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('그림판 예제'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_photo_alternate),
            onPressed: _pickImage,
          ),
        ],
      ),
      body: Stack(
        children: [
          _image != null
              ? Positioned(
            left: position.dx,
            top: position.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  position = Offset(
                    position.dx + details.delta.dx,
                    position.dy + details.delta.dy,
                  );
                });
              },
              onScaleUpdate: (details) {
                setState(() {
                  imageWidth *= details.scale;
                  imageHeight *= details.scale;
                });
              },
              child: Image.file(
                _image!,
                width: imageWidth,
                height: imageHeight,
              ),
            ),
          )
              : Center(
            child: Text('이미지를 선택해주세요'),
          ),
        ],
      ),
    );
  }
}
