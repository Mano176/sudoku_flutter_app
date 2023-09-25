import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku_flutter_app/main.dart';
import 'package:sudoku_flutter_app/sudoku_algorithms.dart';

const double cellSize = 35;
const int maxTries = 3;

class SudokuPage extends StatefulWidget {
  final bool fromSave;
  final int seed;
  final Difficulty difficulty;
  final Function setDarkMode;
  final Function getDarkMode;
  late final List<List<int>> grid;

  SudokuPage(this.fromSave, this.seed, this.difficulty, this.setDarkMode, this.getDarkMode, {super.key}) {
    grid = createSudoku(seed, difficulty);
  }

  @override
  State<StatefulWidget> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> {
  late final Timer timer;
  late final List<List<int>> userGrid;
  late final List<List<int>> solution;
  late final List<List<List<bool>>> notes;
  late final List<List<CellState>> states;
  bool loading = true;
  Set<int> falseCells = {};
  bool noteMode = false;
  int highlightedRow = -1;
  int highlightedColumn = -1;
  int highlightedSquare = -1;
  int timerSeconds = 0;
  int tries = maxTries;

  @override
  void initState() {
    super.initState();
    solution = solveGrid(widget.grid)[0];
    () async {
      final prefs = await SharedPreferences.getInstance();
      if (widget.fromSave) {
        timerSeconds = prefs.getInt("timerSeconds")!;
        tries = prefs.getInt("tries")!;
        states = List<List<CellState>>.from(
            jsonDecode(prefs.getString("states")!).map((e) => List<CellState>.from(e.map((e2) => CellState.fromMap(e2)))).toList());
        userGrid = List.generate(9, (i) => List.generate(9, (j) => 0));
        notes = List.generate(9, (i) => List.generate(9, (j) => List.generate(9, (k) => false)));
        for (List<CellState> changes in states) {
          for (CellState change in changes) {
            userGrid[change.row][change.col] = change.number;
            notes[change.row][change.col] = List.from(change.notes);
          }
        }
      } else {
        states = [];
        List<CellState> latestChanges = [];
        userGrid = [];
        notes = [];
        for (int i = 0; i < widget.grid.length; i++) {
          List<int> row = [];
          List<List<bool>> notesRow = [];
          for (int j = 0; j < widget.grid[i].length; j++) {
            row.add(widget.grid[i][j]);
            notesRow.add(List.generate(9, (k) => false));
            latestChanges.add(CellState(i, j, widget.grid[i][j], notesRow[j]));
          }
          userGrid.add(row);
          notes.add(notesRow);
        }
        saveStates(latestChanges);
        prefs.setInt("seed", widget.seed);
        prefs.setInt("difficulty", widget.difficulty.index);
        prefs.setInt("timerSeconds", timerSeconds);
        prefs.setInt("tries", tries);
      }
    }()
        .then((value) {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          timerSeconds++;
          () async {
            final prefs = await SharedPreferences.getInstance();
            prefs.setInt("timerSeconds", timerSeconds);
          }();
        });
      });
      loading = false;
    });
  }

  void toggleNoteMode() {
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
      if (noteMode) {
        userGrid[highlightedRow][highlightedColumn] = 0;
        notes[highlightedRow][highlightedColumn][number - 1] = !notes[highlightedRow][highlightedColumn][number - 1];
        latestChanges
            .add(CellState(highlightedRow, highlightedColumn, userGrid[highlightedRow][highlightedColumn], notes[highlightedRow][highlightedColumn]));
      } else {
        userGrid[highlightedRow][highlightedColumn] = number;
        notes[highlightedRow][highlightedColumn] = List.generate(9, (i) => false);
        latestChanges
            .add(CellState(highlightedRow, highlightedColumn, userGrid[highlightedRow][highlightedColumn], notes[highlightedRow][highlightedColumn]));
        if (checkGridFull(userGrid)) {
          saveStates(latestChanges);
          if (checkWin()) {
            () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove("seed");
            }();
            timer.cancel();
            showWinDialog();
          } else {
            markFalse();
            tries--;
            if (tries == 0) {
              () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove("seed");
              }();
              showLoseDialog();
            }
            () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setInt("tries", tries);
            }();
          }
          return;
        }
        for (int i = 0; i < 9; i++) {
          if (notes[highlightedRow][i][number - 1]) {
            notes[highlightedRow][i][number - 1] = false;
            latestChanges.add(CellState(highlightedRow, i, userGrid[highlightedRow][i], notes[highlightedRow][i]));
          }
        }
        for (int i = 0; i < 9; i++) {
          if (notes[i][highlightedColumn][number - 1]) {
            notes[i][highlightedColumn][number - 1] = false;
            latestChanges.add(CellState(i, highlightedColumn, userGrid[i][highlightedColumn], notes[i][highlightedColumn]));
          }
        }
        int rowIdentifier = (highlightedRow ~/ 3) * 3;
        int colIdentifier = (highlightedColumn ~/ 3) * 3;
        for (int i = rowIdentifier; i < rowIdentifier + 3; i++) {
          for (int j = colIdentifier; j < colIdentifier + 3; j++) {
            if (notes[i][j][number - 1]) {
              notes[i][j][number - 1] = false;
              latestChanges.add(CellState(i, j, userGrid[i][j], notes[i][j]));
            }
          }
        }
      }
      saveStates(latestChanges);
    });
  }

  void eraseClick() {
    if (highlightedRow == -1 || highlightedColumn == -1 || widget.grid[highlightedRow][highlightedColumn] != 0) {
      return;
    }
    setState(() {
      notes[highlightedRow][highlightedColumn] = List.generate(9, (i) => false);
      userGrid[highlightedRow][highlightedColumn] = 0;
      saveStates(
          [CellState(highlightedRow, highlightedColumn, userGrid[highlightedRow][highlightedColumn], notes[highlightedRow][highlightedColumn])]);
    });
  }

  void undoClick() {
    setState(() {
      List<CellState> latestChanges = states.removeLast();
      for (CellState change in latestChanges) {
        for (int i = states.length - 1; i >= 0; i--) {
          bool found = false;
          for (int j = states[i].length - 1; j >= 0; j--) {
            if (states[i][j].row == change.row && states[i][j].col == change.col) {
              userGrid[change.row][change.col] = states[i][j].number;
              notes[change.row][change.col] = List.from(states[i][j].notes);
              found = true;
              break;
            }
          }
          if (found) {
            break;
          }
        }
      }
      () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("states", jsonEncode(states.map((e) => e.map((e) => e.toMap()).toList()).toList()));
      }();
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
        (highlightedRow != -1 &&
            highlightedColumn != -1 &&
            userGrid[highlightedRow][highlightedColumn] != 0 &&
            userGrid[row][col] == userGrid[highlightedRow][highlightedColumn]);
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

  void showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("You won!"),
          ],
        ),
        surfaceTintColor: Colors.transparent,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Difficulty: ${widget.difficulty.name}"),
            Text("Time: ${secondsToString(timerSeconds)}"),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Back to menu"),
          )
        ],
      ),
    );
  }

  void showLoseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("You Lost!"),
          ],
        ),
        surfaceTintColor: Colors.transparent,
        content: const Text("You ran out of tries!", textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Back to menu"),
          )
        ],
      ),
    );
  }

  void saveStates(List<CellState> statesToSave) {
    states.add(statesToSave);
    () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("states", jsonEncode(states.map((e) => e.map((e) => e.toMap()).toList()).toList()));
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.difficulty.name),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            child: Text(secondsToString(timerSeconds)),
          ),
          Row(children: [
            for (int i = 0; i < maxTries; i++) Icon(Symbols.close, color: i < tries ? null : Colors.grey, size: 20),
          ]),
          IconButton(
            icon: Icon(widget.getDarkMode() ? Symbols.dark_mode : Symbols.light_mode),
            onPressed: () {
              widget.setDarkMode(!widget.getDarkMode());
            },
          ),
        ],
      ),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Column(
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
                      IconButton(onPressed: states.length == 1 ? null : undoClick, icon: const Icon(Symbols.undo)),
                      IconButton(onPressed: eraseClick, icon: const Icon(Symbols.ink_eraser)),
                      IconButton(
                          onPressed: () => toggleNoteMode(),
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

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
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

  @override
  String toString() {
    return toMap().toString();
  }

  Map<String, dynamic> toMap() {
    return {
      "row": row,
      "col": col,
      "number": number,
      "notes": notes,
    };
  }

  static CellState fromMap(Map<String, dynamic> map) {
    return CellState(map["row"], map["col"], map["number"], map["notes"]);
  }
}
