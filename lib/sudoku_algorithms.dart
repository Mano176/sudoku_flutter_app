import 'dart:math';

enum Difficulty {
  easy("Easy", 10),
  middle("Middle", 12.5),
  hard("Hard", 15);

  final String name;
  final double emptyCellsMean;
  const Difficulty(this.name, this.emptyCellsMean);
}

bool checkGrid(List<List<int>> grid) {
  for (List<int> row in grid) {
    for (int cell in row) {
      if (cell == 0) {
        return false;
      }
    }
  }
  return true;
}

late List<List<List<int>>> solutions;
List<List<List<int>>> solveGrid(List<List<int>> grid) {
  solutions = [];
  solveGridRec(grid);
  return solutions;
}

// Recursive backtracking function to check all possible combinations of numbers until a solution is found
void solveGridRec(grid) {
  // Find empty cell
  late int row;
  late int col;
  for (int i = 0; i < 81; i++) {
    row = i ~/ 9;
    col = i % 9;
    if (grid[row][col] != 0) {
      continue;
    }
    for (int value = 1; value < 10; value++) {
      // Check wether the value is already in the row
      if (grid[row].contains(value)) {
        continue;
      }
      // Check wether the value is already in the column
      List<int> columnEntries = [for (int i = 0; i < 9; i++) grid[i][col]];
      if (columnEntries.contains(value)) {
        continue;
      }

      // Check wether the value is used in the square
      int rowIdentifier = (row ~/ 3) * 3;
      int colIdentifier = (col ~/ 3) * 3;
      bool isInSquare = false;
      for (int i = rowIdentifier; i < rowIdentifier + 3; i++) {
        for (int j = colIdentifier; j < colIdentifier + 3; j++) {
          if (grid[i][j] == value) {
            isInSquare = true;
            break;
          }
        }
        if (isInSquare) {
          break;
        }
      }
      if (isInSquare) {
        continue;
      }

      // Set cell to value
      grid[row][col] = value;
      // Check wether it is solved now
      if (checkGrid(grid)) {
        solutions.add(copyGrid(grid));
        break;
      }
      // if not -> solve further
      solveGridRec(grid);
    }
    break;
  }
  // If no right value could be found for the cell, reset it to 0
  grid[row][col] = 0;
}

bool fillGrid(List<List<int>> grid, Random random) {
  // Find empty cell
  late int row;
  late int col;
  for (int i = 0; i < 81; i++) {
    row = i ~/ 9;
    col = i % 9;
    if (grid[row][col] != 0) {
      continue;
    }
    List<int> values = [for (int i = 1; i < 10; i++) i];
    values.shuffle(random);
    for (int value in values) {
      // Check wether the value is already in the row
      if (grid[row].contains(value)) {
        continue;
      }
      // Check wether the value is already in the column
      List<int> columnEntries = [for (int i = 0; i < 9; i++) grid[i][col]];
      if (columnEntries.contains(value)) {
        continue;
      }

      // Check wether the value is used in the square
      int rowIdentifier = (row ~/ 3) * 3;
      int colIdentifier = (col ~/ 3) * 3;
      bool isInSquare = false;
      for (int i = rowIdentifier; i < rowIdentifier + 3; i++) {
        for (int j = colIdentifier; j < colIdentifier + 3; j++) {
          if (grid[i][j] == value) {
            isInSquare = true;
            break;
          }
        }
        if (isInSquare) {
          break;
        }
      }
      if (isInSquare) {
        continue;
      }
      // Set cell to value
      grid[row][col] = value;
      // Check if whole grid is filled now
      if (checkGrid(grid)) {
        return true;
      }
      if (fillGrid(grid, random)) {
        return true;
      }
    }
    break;
  }
  grid[row][col] = 0;
  return false;
}

List<List<int>> createSudoku(int seed, Difficulty difficulty) {
  List<List<int>> grid = [];
  for (int i = 0; i < 9; i++) {
    List<int> row = [];
    for (int j = 0; j < 9; j++) {
      row.add(0);
    }
    grid.add(row);
  }
  Random random = Random(seed);
  fillGrid(grid, random);

  int sample = normalDistSample(1.25, difficulty.emptyCellsMean, random).round();
  int emptyCells = sample < 9 ? 9 : (sample > 16 ? 16 : sample);
  while (emptyCells > 0) {
    late int row;
    late int col;
    do {
      row = random.nextInt(9);
      col = random.nextInt(9);
    } while (grid[row][col] == 0);
    int backup = grid[row][col];
    grid[row][col] = 0;
    List<List<int>> copiedGrid = copyGrid(grid);
    List<List<List<int>>> solutions = solveGrid(copiedGrid);
    if (solutions.length != 1) {
      grid[row][col] = backup;
    } else {
      emptyCells--;
    }
  }
  return grid;
}

List<List<int>> copyGrid(List<List<int>> grid) {
  List<List<int>> newGrid = [];
  for (List<int> row in grid) {
    List<int> newRow = [];
    for (int value in row) {
      newRow.add(value);
    }
    newGrid.add(newRow);
  }
  return newGrid;
}

double normalDistSample(double std, double mean, Random random) {
  // Box-Muller polar form algorithm
  var x1 = 0.0;
  var x2 = 0.0;
  var w = 0.0;
  do {
    x1 = (2.0 * random.nextDouble()) - 1.0;
    x2 = (2.0 * random.nextDouble()) - 1.0;
    w = (x1 * x1) + (x2 * x2);
  } while (w >= 1.0);
  final r = x1 * sqrt((-2.0 * log(w)) / w);
  return r * std + mean;
}
