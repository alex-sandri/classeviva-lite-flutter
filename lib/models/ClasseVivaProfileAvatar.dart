import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class ClasseVivaProfileAvatar
{
  final String text;

  final Color backgroundColor;

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