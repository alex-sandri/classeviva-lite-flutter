import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeManager with ChangeNotifier
{
  ThemeMode _themeMode;

  ThemeMode get themeMode {
    final Box preferences = Hive.box("preferences");

    final String theme = preferences.get("theme");

    switch (theme)
    {
      case "light": _themeMode = ThemeMode.light; break;
      case "dark": _themeMode = ThemeMode.dark; break;
      default: _themeMode = ThemeMode.system; break;
    }

    return _themeMode;
  }

  void setTheme(String theme) {
    switch (theme)
    {
      case "system": _themeMode = ThemeMode.system; break;
      case "light": _themeMode = ThemeMode.light; break;
      case "dark": _themeMode = ThemeMode.dark; break;
    }

    final Box preferences = Hive.box("preferences");

    preferences.put("theme", theme);

    notifyListeners();
  }

  static bool isLightTheme(BuildContext context) => Theme.of(context).brightness == Brightness.light;
}