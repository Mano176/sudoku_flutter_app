import 'package:flutter/material.dart';

class SudokuPage extends StatelessWidget {
  final String mode;

  const SudokuPage(this.mode, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mode),
      ),
      body: const Center(
        child: Text("Sudoku"),
      ),
    );
  }
}
