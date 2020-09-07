import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'ClasseVivaProfileAvatar.g.dart';

@HiveType(typeId: 2)
class ClasseVivaProfileAvatar
{
  @HiveField(0)
  final String text;

  @HiveField(1)
  final int backgroundColorValue;

  @HiveField(2)
  final int foregroundColorValue;

  ClasseVivaProfileAvatar({
    @required this.text,
    @required this.backgroundColorValue,
    @required this.foregroundColorValue,
  });

  Widget toWidget() => CircleAvatar(
    child: Text(
      text,
      style: TextStyle(
        color: Color(foregroundColorValue),
      ),
    ),
    backgroundColor: Color(backgroundColorValue),
  );
}