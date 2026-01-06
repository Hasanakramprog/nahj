import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _fontSizeKey = 'fontSize';
  static const String _themeModeKey = 'themeMode';
  static const String _fontFamilyKey = 'fontFamily';
  static const String _useHistoricBackgroundKey = 'useHistoricBackground';
  static const String _useSystemThemeKey = 'useSystemTheme';

  double _fontSize = 20.0;
  ThemeMode _themeMode = ThemeMode.system;
  String _fontFamily = 'Amiri';
  bool _useHistoricBackground = true;
  bool _useSystemTheme = true;

  double get fontSize => _fontSize;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get fontFamily => _fontFamily;
  bool get useHistoricBackground => _useHistoricBackground;
  bool get useSystemTheme => _useSystemTheme;

  // Helper method to check if dark mode is active (considering system theme)
  bool isDarkModeActive(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  SettingsProvider() {
    _loadSettings().catchError((error) {
      debugPrint('Error loading settings: $error');
      // Continue with defaults if loading fails
    });
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
    'Amiri':
        ({
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
        }) => const TextStyle(fontFamily: 'Amiri').copyWith(
          color: color,
          backgroundColor: backgroundColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          wordSpacing: wordSpacing,
          textBaseline: textBaseline,
          height: height,
          locale: locale,
          foreground: foreground,
          background: background,
          shadows: shadows,
          fontFeatures: fontFeatures,
          decoration: decoration,
          decorationColor: decorationColor,
          decorationStyle: decorationStyle,
          decorationThickness: decorationThickness,
        ),
    'Tajawal':
        ({
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
        }) => const TextStyle(fontFamily: 'Tajawal').copyWith(
          color: color,
          backgroundColor: backgroundColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          wordSpacing: wordSpacing,
          textBaseline: textBaseline,
          height: height,
          locale: locale,
          foreground: foreground,
          background: background,
          shadows: shadows,
          fontFeatures: fontFeatures,
          decoration: decoration,
          decorationColor: decorationColor,
          decorationStyle: decorationStyle,
          decorationThickness: decorationThickness,
        ),
    'Cairo':
        ({
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
        }) => const TextStyle(fontFamily: 'Cairo').copyWith(
          color: color,
          backgroundColor: backgroundColor,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          letterSpacing: letterSpacing,
          wordSpacing: wordSpacing,
          textBaseline: textBaseline,
          height: height,
          locale: locale,
          foreground: foreground,
          background: background,
          shadows: shadows,
          fontFeatures: fontFeatures,
          decoration: decoration,
          decorationColor: decorationColor,
          decorationStyle: decorationStyle,
          decorationThickness: decorationThickness,
        ),
  };

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _fontSize = prefs.getDouble(_fontSizeKey) ?? 20.0;
      _useSystemTheme = prefs.getBool(_useSystemThemeKey) ?? true;

      if (_useSystemTheme) {
        _themeMode = ThemeMode.system;
      } else {
        final themeModeIndex =
            prefs.getInt(_themeModeKey) ?? ThemeMode.light.index;
        _themeMode = ThemeMode.values[themeModeIndex];
      }

      _fontFamily = prefs.getString(_fontFamilyKey) ?? 'Amiri';
      _useHistoricBackground = prefs.getBool(_useHistoricBackgroundKey) ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
      // Continue with defaults
    }
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
    if (_useSystemTheme) {
      // If currently using system theme, switch to manual light mode
      _useSystemTheme = false;
      _themeMode = ThemeMode.light;
    } else if (_themeMode == ThemeMode.light) {
      // If manual light mode, switch to manual dark mode
      _themeMode = ThemeMode.dark;
    } else {
      // If manual dark mode, switch back to system theme
      _useSystemTheme = true;
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useSystemThemeKey, _useSystemTheme);
    await prefs.setInt(_themeModeKey, _themeMode.index);
  }

  Future<void> setUseSystemTheme(bool value) async {
    _useSystemTheme = value;
    if (value) {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useSystemThemeKey, value);
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
