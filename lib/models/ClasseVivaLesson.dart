import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'ClasseVivaLesson.g.dart';

@HiveType(typeId: 12)
class ClasseVivaLesson
{
  @HiveField(0)
  final String teacher;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String description;

  ClasseVivaLesson({
    @required this.teacher,
    @required this.date,
    @required this.description,
  });
}