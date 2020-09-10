import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'ClasseVivaCalendarLesson.g.dart';

@HiveType(typeId: 6)
class ClasseVivaCalendarLesson
{
  @HiveField(0)
  final String teacher;

  @HiveField(1)
  final String subject;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final int hour;

  @HiveField(5)
  final Duration duration;

  ClasseVivaCalendarLesson({
    @required this.teacher,
    @required this.subject,
    @required this.type,
    @required this.description,
    @required this.hour,
    @required this.duration,
  });
}