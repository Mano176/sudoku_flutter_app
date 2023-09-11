import 'package:flutter/material.dart';

import 'sudoku_page.dart';

class StartPage extends StatelessWidget {
  final Function setDarkMode;
  final Function getDarkMode;

  const StartPage(this.setDarkMode, this.getDarkMode, {super.key});

  static final difficulties = ["Easy", "Middle", "Hard"];

  startSoduko(context, mode) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SudokuPage(mode, setDarkMode, getDarkMode)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(getDarkMode() ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              setDarkMode(!getDarkMode());
            },
          ),
        ],
      ),
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
                for (String difficulty in difficulties)
                  ElevatedButton(
                      onPressed: () => startSoduko(context, difficulty),
                      child: Text(difficulty)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
