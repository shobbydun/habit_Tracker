import 'package:flutter/material.dart';
import 'package:habit_tracker/theme/dark_mode.dart';
import 'package:habit_tracker/theme/light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  // Initially, it's light mode
  ThemeData _themeData = lightmode;

  // Get current theme
  ThemeData get themeData => _themeData;

  // Is current theme dark mode
  bool get isDarkMode => _themeData == darkmode;

  // Set theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  // Toggle from light to dark mode
  void toggleTheme() {
    if (_themeData == lightmode) {
      themeData = darkmode;
    } else {
      themeData = lightmode;
    }
  }
}
