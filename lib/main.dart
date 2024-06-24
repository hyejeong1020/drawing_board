import 'package:drawing_board/presentation/view/color_picker_screen.dart';
import 'package:drawing_board/presentation/view/drawing_boaed_screen.dart';
import 'package:drawing_board/presentation/view/drawing_remover.dart';
import 'package:drawing_board/presentation/view/drawing_page.dart';
import 'package:drawing_board/presentation/view_model/drawing_view_model.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final DrawingViewModel drawingViewModel = DrawingViewModel();

    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: Colors.white),
        dialogTheme: DialogTheme(backgroundColor: Colors.white),
        textTheme: TextTheme(
          bodySmall: TextStyle(fontSize: 14),
          bodyMedium: TextStyle(fontSize: 16),
          bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottomAppBarTheme: BottomAppBarTheme(color: Colors.white)
      ),
      debugShowCheckedModeBanner: false,
      home: DrawingBoardScreen(drawingViewModel: drawingViewModel),
    );
  }
}
