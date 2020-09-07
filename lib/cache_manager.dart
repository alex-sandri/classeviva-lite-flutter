import 'package:hive/hive.dart';

class CacheManager
{
  static Box _box;

  static dynamic get(String key) => _box.get(key);

  static void set(String key, dynamic value) => _box.put(key, value);

  static Future<void> initialize() async => _box = await Hive.openBox("cache");
}