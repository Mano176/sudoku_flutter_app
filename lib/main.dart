import 'package:flutter/material.dart';
import 'package:sudoku_flutter_app/sudoku_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku',
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.light,
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  static final modes = ["Leicht", "Mittel", "Schwer"];

  startSoduko(context, mode) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SudokuPage(mode)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Image.asset(
              "assets/icon.png",
              width: 100,
              height: 100,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var mode in modes)
                  ElevatedButton(
                      onPressed: () => startSoduko(context, mode),
                      child: Text(mode)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
