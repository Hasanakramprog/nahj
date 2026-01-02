import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _fontSizeKey = 'fontSize';
  static const String _themeModeKey = 'themeMode';
  static const String _fontFamilyKey = 'fontFamily';
  static const String _useHistoricBackgroundKey = 'useHistoricBackground';

  double _fontSize = 20.0;
  ThemeMode _themeMode = ThemeMode.light;
  String _fontFamily = 'Amiri';
  bool _useHistoricBackground = true;

  double get fontSize => _fontSize;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get fontFamily => _fontFamily;
  bool get useHistoricBackground => _useHistoricBackground;

  SettingsProvider() {
    _loadSettings();
  }

  final Map<
    String,
    TextStyle Function({
      TextStyle? textStyle,
      Color? color,
      Color? backgroundColor,
      double? fontSize,
      FontWeight? fontWeight,
      FontStyle? fontStyle,
      double? letterSpacing,
      double? wordSpacing,
      TextBaseline? textBaseline,
      double? height,
      Locale? locale,
      Paint? foreground,
      Paint? background,
      List<Shadow>? shadows,
      List<FontFeature>? fontFeatures,
      TextDecoration? decoration,
      Color? decorationColor,
      TextDecorationStyle? decorationStyle,
      double? decorationThickness,
    })
  >
  fonts = {
    'Amiri': GoogleFonts.amiri,
    'Tajawal': GoogleFonts.tajawal,
    'Cairo': GoogleFonts.cairo,
  };

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble(_fontSizeKey) ?? 20.0;
    final themeModeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.light.index;
    _themeMode = ThemeMode.values[themeModeIndex];
    _fontFamily = prefs.getString(_fontFamilyKey) ?? 'Amiri';
    _useHistoricBackground = prefs.getBool(_useHistoricBackgroundKey) ?? true;
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size);
  }

  Future<void> setUseHistoricBackground(bool value) async {
    _useHistoricBackground = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useHistoricBackgroundKey, value);
  }

  Future<void> setFontFamily(String family) async {
    if (fonts.containsKey(family)) {
      _fontFamily = family;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fontFamilyKey, family);
    }
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
