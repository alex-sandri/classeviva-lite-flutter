import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ThemeManager
{
  static ThemeMode get themeMode {
    final Box preferences = Hive.box("preferences");

    final String theme = preferences.get("theme");

    switch (theme)
    {
      case "light": return ThemeMode.light;
      case "dark": return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  static void setTheme(String theme) {
    final Box preferences = Hive.box("preferences");

    preferences.put("theme", theme);

    Get.changeThemeMode(ThemeManager.themeMode);
  }

  static bool isLightTheme(BuildContext context) => Theme.of(context).brightness == Brightness.light;
}