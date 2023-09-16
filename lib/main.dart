import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/start_page.dart';

void main() async {
  if (!kIsWeb && Platform.isWindows) {
    WidgetsFlutterBinding.ensureInitialized();
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitle('Sudoku');
    });
  }
  runApp(const MyApp());
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    () async {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        darkMode = prefs.getBool("darkMode") ?? false;
      });
    }();
  }

  void setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      darkMode = value;
      prefs.setBool("darkMode", value);
    });
  }

  bool getDarkMode() {
    return darkMode;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light().copyWith(primary: Colors.black),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: const ColorScheme.dark().copyWith(primary: Colors.white),
        useMaterial3: true,
      ),
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      home: StartPage(setDarkMode, getDarkMode),
    );
  }
}
