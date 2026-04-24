import 'package:flutter/material.dart';
import '../storage/prefs_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    loadTheme();
  }

  Future<void> loadTheme() async {
    bool isDark = await PrefsService.getTheme();

    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;

      await PrefsService.saveTheme(true);
    } else {
      _themeMode = ThemeMode.light;

      await PrefsService.saveTheme(false);
    }

    notifyListeners();
  }
}
