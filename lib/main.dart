import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'start_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowManager.instance.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitle('Sudoku');
  });

  runApp(const MyApp());
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
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      home: StartPage(setDarkMode, getDarkMode),
    );
  }
}
