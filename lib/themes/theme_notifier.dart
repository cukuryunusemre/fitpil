import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeData _currentTheme = AppTheme.lightTheme;
  bool _isDarkTheme = false;

  ThemeData get currentTheme => _currentTheme;
  bool get isDarkTheme => _isDarkTheme;

  void toggleTheme() {
    if (_isDarkTheme) {
      _currentTheme = AppTheme.lightTheme;
      _isDarkTheme = false;
    } else {
      _currentTheme = AppTheme.darkTheme;
      _isDarkTheme = true;
    }
    notifyListeners();
  }
}
