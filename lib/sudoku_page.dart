import 'package:flutter/material.dart';

class SudokuPage extends StatelessWidget {
  final String difficulty;
  final Function setDarkMode;
  final Function getDarkMode;

  const SudokuPage(this.difficulty, this.setDarkMode, this.getDarkMode,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(difficulty),
        actions: [
          IconButton(
            icon: Icon(getDarkMode() ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              setDarkMode(!getDarkMode());
            },
          ),
        ],
      ),
      body: const Center(
        child: Text("Sudoku"),
      ),
    );
  }
}
