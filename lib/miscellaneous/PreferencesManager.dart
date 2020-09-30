import 'package:hive/hive.dart';

class PreferencesManager
{
  static Box _box = Hive.box("preferences");

  static void get(String key) => _box.get(key);

  static void set(String key, dynamic value) => _box.put(key, value);

  static Future<void> initialize() async => _box = await Hive.openBox("preferences");
}