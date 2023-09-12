import 'package:flutter/material.dart';
import 'package:sudoku_flutter_app/sudoku_algorithms.dart';

class SudokuPage extends StatelessWidget {
  final Difficulty difficulty;
  final Function setDarkMode;
  final Function getDarkMode;
  late final List<List<int>> grid;

  SudokuPage(this.difficulty, this.setDarkMode, this.getDarkMode, {super.key}) {
    grid = createSudoku(1234, difficulty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(difficulty.name),
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
            for (List<int> row in grid)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int value in row)
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: Center(
                        child: Text(value == 0 ? "" : value.toString()),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
