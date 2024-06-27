import 'package:drawing_board/presentation/view/image_download_example_screen.dart';
import 'package:drawing_board/presentation/view/drawing_board_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: Colors.white),
        dialogTheme: DialogTheme(backgroundColor: Colors.white),
        bottomAppBarTheme: BottomAppBarTheme(color: Colors.white),
        textTheme: TextTheme(
          bodySmall: TextStyle(fontSize: 14),
          bodyMedium: TextStyle(fontSize: 16),
          bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: DrawingBoardScreen(),
    );
  }
}
