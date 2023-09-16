import 'dart:math';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku_flutter_app/main.dart';
import '../sudoku_algorithms.dart';
import 'sudoku_page.dart';

class StartPage extends StatefulWidget {
  final Function setDarkMode;
  final Function getDarkMode;

  const StartPage(this.setDarkMode, this.getDarkMode, {super.key});

  @override
  State<StatefulWidget> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  int? savedSeed;
  Difficulty? savedDifficulty;
  int? savedTimerSeconds;

  void startSoduko(BuildContext context, bool fromSave, int seed, Difficulty difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SudokuPage(fromSave, seed, difficulty, widget.setDarkMode, widget.getDarkMode)),
    ).then((value) => loadSavedData());
  }

  void loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedSeed = prefs.getInt("seed");
      int? savedDifficultyIndex = prefs.getInt("difficulty");
      savedDifficulty = savedDifficultyIndex != null ? Difficulty.values[savedDifficultyIndex] : null;
      savedTimerSeconds = prefs.getInt("timerSeconds");
    });
  }

  @override
  void initState() {
    super.initState();
    loadSavedData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Image.asset(
                "assets/icon.png",
                width: 150,
                height: 150,
              ),
            ),
            const Text("Resume game:"),
            SizedBox(
              width: 120,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: OutlinedButton(
                  onPressed: savedSeed == null ? null : () => startSoduko(context, true, savedSeed!, savedDifficulty!),
                  child: Text(savedSeed == null ? "No game saved" : "${savedDifficulty!.name} ${secondsToString(savedTimerSeconds!)}",
                      textAlign: TextAlign.center),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text("New game:"),
            ),
            for (Difficulty difficulty in Difficulty.values)
              SizedBox(
                width: 120,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: OutlinedButton(
                    onPressed: () => savedSeed == null
                        ? startSoduko(context, false, Random().nextInt(2 ^ 32), difficulty)
                        : showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text("Start new game?"),
                              content: const Text("You will lose your current progress."),
                              surfaceTintColor: Colors.transparent,
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    startSoduko(context, false, Random().nextInt(2 ^ 32), difficulty);
                                  },
                                  child: const Text("Start"),
                                ),
                              ],
                            ),
                          ),
                    child: Text(difficulty.name),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
