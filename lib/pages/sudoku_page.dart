import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sudoku_flutter_app/sudoku_algorithms.dart';

class SudokuPage extends StatefulWidget {
  final int seed;
  final Difficulty difficulty;
  final Function setDarkMode;
  final Function getDarkMode;
  late final List<List<int>> grid;

  SudokuPage(this.seed, this.difficulty, this.setDarkMode, this.getDarkMode, {super.key}) {
    grid = createSudoku(seed, difficulty);
  }

  @override
  State<StatefulWidget> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> {
  int highlightedRow = -1;
  int highlightedColumn = -1;
  int highlightedSquare = -1;

  void setHighlight(int highlightedRow, int highlightedColumn) {
    setState(() {
      if (this.highlightedRow == highlightedRow && this.highlightedColumn == highlightedColumn) {
        this.highlightedRow = -1;
        this.highlightedColumn = -1;
        highlightedSquare = -1;
        return;
      }
      this.highlightedRow = highlightedRow;
      this.highlightedColumn = highlightedColumn;
      highlightedSquare = (highlightedRow ~/ 3) * 3 + (highlightedColumn ~/ 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.difficulty.name),
        actions: [
          IconButton(
            icon: Icon(widget.getDarkMode() ? Symbols.dark_mode : Symbols.light_mode),
            onPressed: () {
              widget.setDarkMode(!widget.getDarkMode());
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Column(
              children: [
                for (int row = 0; row < widget.grid.length; row++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int col = 0; col < widget.grid[row].length; col++)
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              color: row == highlightedRow && col == highlightedColumn
                                  ? Colors.grey.shade400
                                  : row == highlightedRow || col == highlightedColumn || (row ~/ 3) * 3 + (col ~/ 3) == highlightedSquare
                                      ? Colors.grey.shade500
                                      : null,
                            ),
                            child: TextButton(
                              onPressed: () => setHighlight(row, col),
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: Center(
                                child: Text(widget.grid[row][col] == 0 ? "" : widget.grid[row][col].toString()),
                              ),
                            ),
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
