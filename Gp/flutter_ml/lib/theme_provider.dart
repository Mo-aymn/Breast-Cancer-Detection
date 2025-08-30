import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  Color _backgroundColor = Colors.white;
  Color _textColor = Colors.black;

  bool get isDarkMode => _isDarkMode;
  Color get backgroundColor => _backgroundColor;
  Color get textColor => _textColor;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _backgroundColor = _isDarkMode ? Colors.black : Colors.white;
    _textColor = _isDarkMode ? Colors.white : Colors.black;
    notifyListeners();
  }

  ThemeData getTheme() {
    return _isDarkMode ? ThemeData.dark() : ThemeData.light();
  }
}