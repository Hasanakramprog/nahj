import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _fontSizeKey = 'fontSize';
  static const String _themeModeKey = 'themeMode';

  double _fontSize = 20.0;
  ThemeMode _themeMode = ThemeMode.light;

  double get fontSize => _fontSize;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble(_fontSizeKey) ?? 20.0;
    final themeModeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.light.index;
    _themeMode = ThemeMode.values[themeModeIndex];
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size);
  }

  Future<void> toggleThemeMode() async {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, _themeMode.index);
  }

  Future<void> increaseFontSize() async {
    if (_fontSize < 32) {
      await setFontSize(_fontSize + 2);
    }
  }

  Future<void> decreaseFontSize() async {
    if (_fontSize > 14) {
      await setFontSize(_fontSize - 2);
    }
  }
}
