import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sudoku_flutter_app/sudoku_algorithms.dart';

const double cellSize = 35;

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
  late final List<List<int>> solution;
  late final List<List<List<bool>>> notes;
  final List<List<CellState>> states = [];
  Set<int> falseCells = {};
  bool noteMode = false;
  bool won = false;
  int highlightedRow = -1;
  int highlightedColumn = -1;
  int highlightedSquare = -1;
  int timerSeconds = 0;

  @override
  void initState() {
    super.initState();
    userGrid = copyGrid(widget.grid);
    solution = solveGrid(widget.grid)[0];
    notes = List.generate(9, (i) => List.generate(9, (j) => List.generate(9, (k) => false)));
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (won) {
        timer.cancel();
        return;
      }
      setState(() {
        timerSeconds++;
      });
    });
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
      if (!noteMode && userGrid[highlightedRow][highlightedColumn] == number) {
        return;
      }
      falseCells.remove(highlightedRow * 9 + highlightedColumn);
      List<CellState> latestChanges = [];
      CellState state =
          CellState(highlightedRow, highlightedColumn, userGrid[highlightedRow][highlightedColumn], notes[highlightedRow][highlightedColumn]);
      latestChanges.add(state);
      if (noteMode) {
        userGrid[highlightedRow][highlightedColumn] = 0;
        notes[highlightedRow][highlightedColumn][number - 1] = !notes[highlightedRow][highlightedColumn][number - 1];
      } else {
        userGrid[highlightedRow][highlightedColumn] = number;
        notes[highlightedRow][highlightedColumn] = List.generate(9, (i) => false);
        if (checkGridFull(userGrid)) {
          if (checkWin()) {
            won = true;
          } else {
            markFalse();
          }
          return;
        }
        for (int i = 0; i < 9; i++) {
          if (notes[highlightedRow][i][number - 1]) {
            latestChanges.add(CellState(highlightedRow, i, userGrid[highlightedRow][i], notes[highlightedRow][i]));
            notes[highlightedRow][i][number - 1] = false;
          }
        }
        for (int i = 0; i < 9; i++) {
          if (notes[i][highlightedColumn][number - 1]) {
            latestChanges.add(CellState(i, highlightedColumn, userGrid[i][highlightedColumn], notes[i][highlightedColumn]));
            notes[i][highlightedColumn][number - 1] = false;
          }
        }
        int rowIdentifier = (highlightedRow ~/ 3) * 3;
        int colIdentifier = (highlightedColumn ~/ 3) * 3;
        for (int i = rowIdentifier; i < rowIdentifier + 3; i++) {
          for (int j = colIdentifier; j < colIdentifier + 3; j++) {
            if (notes[i][j][number - 1]) {
              latestChanges.add(CellState(i, j, userGrid[i][j], notes[i][j]));
              notes[i][j][number - 1] = false;
            }
          }
        }
      }
      states.add(latestChanges);
    });
  }

  void eraseClick() {
    if (highlightedRow == -1 || highlightedColumn == -1 || widget.grid[highlightedRow][highlightedColumn] != 0) {
      return;
    }
    setState(() {
      CellState state =
          CellState(highlightedRow, highlightedColumn, userGrid[highlightedRow][highlightedColumn], notes[highlightedRow][highlightedColumn]);
      states.add([state]);
      notes[highlightedRow][highlightedColumn] = List.generate(9, (i) => false);
      userGrid[highlightedRow][highlightedColumn] = 0;
    });
  }

  void undoClick() {
    if (states.isEmpty) {
      return;
    }
    setState(() {
      List<CellState> latestChanges = states.removeLast();
      for (CellState state in latestChanges) {
        userGrid[state.row][state.col] = state.number;
        notes[state.row][state.col] = state.notes;
      }
    });
  }

  bool checkWin() {
    for (int row = 0; row < userGrid.length; row++) {
      for (int col = 0; col < userGrid[row].length; col++) {
        if (userGrid[row][col] != solution[row][col]) {
          return false;
        }
      }
    }
    return true;
  }

  void markFalse() {
    for (int row = 0; row < userGrid.length; row++) {
      for (int col = 0; col < userGrid[row].length; col++) {
        if (userGrid[row][col] != solution[row][col]) {
          falseCells.add(row * 9 + col);
        }
      }
    }
  }

  bool isHighlighted(int row, int col) {
    return row == highlightedRow ||
        col == highlightedColumn ||
        (row ~/ 3) * 3 + (col ~/ 3) == highlightedSquare ||
        (highlightedRow != -1 && highlightedColumn != -1 && userGrid[row][col] == userGrid[highlightedRow][highlightedColumn]);
  }

  Color? getCellColor(int row, int col) {
    Color highlightColor = widget.getDarkMode() ? Colors.white : Colors.black;
    if (row == highlightedRow && col == highlightedColumn) {
      return highlightColor.withOpacity(0.75);
    }
    if (isHighlighted(row, col)) {
      return highlightColor.withOpacity(0.5);
    }
    return null;
  }

  Color getCellTextColor(int row, int col) {
    if (falseCells.contains(row * 9 + col)) {
      return Colors.red;
    }
    Color textColor = widget.getDarkMode() ? Colors.white : Colors.black;
    Color textColorHighlighted = widget.getDarkMode() ? Colors.black : Colors.white;
    Color returnColor = isHighlighted(row, col) ? textColorHighlighted : textColor;
    returnColor = widget.grid[row][col] == 0 ? returnColor.withOpacity(0.5) : returnColor;
    return returnColor;
  }

  Border getBorder(int row, int col) {
    Color colorOutside = Colors.black;
    Color colorInside = Colors.black.withOpacity(0.5);
    Color top = row % 3 == 0 ? colorOutside : colorInside;
    Color bottom = row % 3 == 2 ? colorOutside : colorInside;
    Color left = col % 3 == 0 ? colorOutside : colorInside;
    Color right = col % 3 == 2 ? colorOutside : colorInside;
    return Border(
      top: BorderSide(color: top, width: 1.0),
      bottom: BorderSide(color: bottom, width: 1.0),
      left: BorderSide(color: left, width: 1.0),
      right: BorderSide(color: right, width: 1.0),
    );
  }

  String secondsToString(int seconds) {
    int minutes = seconds ~/ 60;
    seconds = seconds % 60;
    int hours = minutes ~/ 60;
    minutes = minutes % 60;
    String hoursString = hours == 0 ? "" : "$hours:";
    String minutesString = minutes.toString().padLeft(2, "0");
    String secondsString = seconds.toString().padLeft(2, "0");
    return "$hoursString$minutesString:$secondsString";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.difficulty.name),
        actions: [
          Text(
            secondsToString(timerSeconds),
          ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                for (int row = 0; row < userGrid.length; row++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int col = 0; col < userGrid[row].length; col++)
                        SizedBox(
                          width: cellSize,
                          height: cellSize,
                          child: Container(
                            decoration: BoxDecoration(
                              border: getBorder(row, col),
                              color: getCellColor(row, col),
                            ),
                            child: InkWell(
                              onTap: () => setHighlight(row, col),
                              child: userGrid[row][col] == 0
                                  ? GridView.count(crossAxisCount: 3, children: [
                                      for (int i = 0; i < 9; i++)
                                        Center(
                                          child: Text(
                                            (i + 1).toString(),
                                            textScaler: const TextScaler.linear(0.6),
                                            style: TextStyle(
                                              color: notes[row][col][i] ? getCellTextColor(row, col) : Colors.transparent,
                                            ),
                                          ),
                                        ),
                                    ])
                                  : Center(child: Text(userGrid[row][col].toString(), style: TextStyle(color: getCellTextColor(row, col)))),
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
                IconButton(onPressed: states.isEmpty ? null : undoClick, icon: const Icon(Symbols.undo)),
                IconButton(onPressed: eraseClick, icon: const Icon(Symbols.ink_eraser)),
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
                      width: cellSize,
                      height: cellSize,
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

class CellState {
  final int row;
  final int col;
  final int number;
  late final List<bool> notes;

  CellState(this.row, this.col, this.number, notes) {
    this.notes = List.from(notes);
  }
}
