import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
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
            icon: Icon(getDarkMode() ? Symbols.dark_mode : Symbols.light_mode),
            onPressed: () {
              setDarkMode(!getDarkMode());
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Column(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: () => {}, icon: const Icon(Symbols.undo)),
                IconButton(onPressed: () => {}, icon: const Icon(Symbols.ink_eraser)),
                IconButton(
                    onPressed: () => {},
                    icon: const Icon(
                      Symbols.edit,
                      fill: 1,
                    )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= 9; i++)
                  SizedBox(
                      width: 30,
                      height: 30,
                      child: TextButton(
                          onPressed: () => {},
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Text(
                            i.toString(),
                            textAlign: TextAlign.center,
                          ))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
