import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// Source
// https://github.com/hivedb/hive_flutter/pull/2/commits/b5bd17522213503daf5e33fb9d09f384595f331f

class ColorAdapter extends TypeAdapter<Color> {
  @override
  Color read(BinaryReader reader) {
    final colorValue = reader.readInt();
    return Color(colorValue);
  }

  @override
  void write(BinaryWriter writer, Color obj) {
    writer.writeInt(obj.value);
  }

  @override
  int get typeId => 200;
}