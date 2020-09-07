import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'ClasseVivaProfileAvatar.g.dart';

@HiveType(typeId: 2)
class ClasseVivaProfileAvatar
{
  @HiveField(0)
  final String text;

  @HiveField(1)
  final Color backgroundColor;

  @HiveField(2)
  final Color foregroundColor;

  ClasseVivaProfileAvatar({
    @required this.text,
    @required this.backgroundColor,
    @required this.foregroundColor,
  });

  Widget toWidget() => CircleAvatar(
    child: Text(
      text,
      style: TextStyle(
        color: foregroundColor,
      ),
    ),
    backgroundColor: backgroundColor,
  );
}