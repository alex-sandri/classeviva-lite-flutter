import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager with ChangeNotifier
{
  ThemeMode _themeMode;

  ThemeMode get themeMode {
    if (_themeMode == null) _themeMode = ThemeMode.system;

    return _themeMode;
  }

  void setTheme(String theme) async {
    switch (theme)
    {
      case "system": _themeMode = ThemeMode.system; break;
      case "light": _themeMode = ThemeMode.light; break;
      case "dark": _themeMode = ThemeMode.dark; break;
    }

    final SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.setString("theme", theme);

    notifyListeners();
  }

  static bool isLightTheme(BuildContext context) => Theme.of(context).brightness == Brightness.light;
}