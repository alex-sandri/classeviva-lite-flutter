import 'package:classeviva_lite/miscellaneous/PreferencesManager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeManager
{
  static ThemeMode get themeMode {
    final String theme = PreferencesManager.get("theme");

    switch (theme)
    {
      case "light": return ThemeMode.light;
      case "dark": return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  static void setTheme(String theme) {
    PreferencesManager.set("theme", theme);

    Get.changeThemeMode(ThemeManager.themeMode);
  }

  static bool isLightTheme(BuildContext context) => Theme.of(context).brightness == Brightness.light;
}