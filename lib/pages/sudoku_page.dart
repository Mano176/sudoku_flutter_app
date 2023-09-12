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
  late final List<List<int>> userGrid;
  late final List<List<List<bool>>> notes;
  bool noteMode = false;
  int highlightedRow = -1;
  int highlightedColumn = -1;
  int highlightedSquare = -1;

  @override
  void initState() {
    super.initState();
    userGrid = copyGrid(widget.grid);
    notes = List.generate(9, (i) => List.generate(9, (j) => List.generate(9, (k) => false)));
  }

  void toggleNodeMode() {
    setState(() {
      noteMode = !noteMode;
    });
  }

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

  void numberClick(int number) {
    if (highlightedRow == -1 || highlightedColumn == -1 || widget.grid[highlightedRow][highlightedColumn] != 0) {
      return;
    }
    setState(() {
      if (noteMode) {
        notes[highlightedRow][highlightedColumn][number - 1] = !notes[highlightedRow][highlightedColumn][number - 1];
      } else {
        userGrid[highlightedRow][highlightedColumn] = number;
      }
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
                for (int row = 0; row < userGrid.length; row++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int col = 0; col < userGrid[row].length; col++)
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              color: () {
                                Color highlightColor = widget.getDarkMode() ? Colors.white : Colors.black;
                                if (row == highlightedRow && col == highlightedColumn) {
                                  return highlightColor.withOpacity(0.75);
                                }
                                if (row == highlightedRow || col == highlightedColumn || (row ~/ 3) * 3 + (col ~/ 3) == highlightedSquare) {
                                  return highlightColor.withOpacity(0.5);
                                }
                                return null;
                              }(),
                            ),
                            child: TextButton(
                              onPressed: () => setHighlight(row, col),
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: Center(
                                child: Text(
                                  userGrid[row][col] == 0 ? "" : userGrid[row][col].toString(),
                                  style: TextStyle(color: () {
                                    Color textColor = widget.getDarkMode() ? Colors.white : Colors.black;
                                    Color textColorHighlighted = widget.getDarkMode() ? Colors.black : Colors.white;
                                    bool isHighlighted =
                                        row == highlightedRow || col == highlightedColumn || (row ~/ 3) * 3 + (col ~/ 3) == highlightedSquare;
                                    Color returnColor = isHighlighted ? textColorHighlighted : textColor;
                                    returnColor = widget.grid[row][col] == 0 ? returnColor.withOpacity(0.5) : returnColor;
                                    return returnColor;
                                  }()),
                                ),
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
                    onPressed: () => toggleNodeMode(),
                    icon: Icon(
                      Symbols.edit,
                      fill: noteMode ? 1 : 0,
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
                          onPressed: () => numberClick(i),
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
