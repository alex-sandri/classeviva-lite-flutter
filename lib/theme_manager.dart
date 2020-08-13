import 'package:flutter/material.dart';

class ThemeManager with ChangeNotifier
{
  ThemeMode _themeMode;

  ThemeMode get themeMode {
    if (_themeMode == null) _themeMode = ThemeMode.system;

    return _themeMode;
  }

  setTheme(String theme) async {
    switch (theme)
    {
      case "system": _themeMode = ThemeMode.system; break;
      case "light": _themeMode = ThemeMode.light; break;
      case "dark": _themeMode = ThemeMode.dark; break;
    }

    notifyListeners();
  }
}