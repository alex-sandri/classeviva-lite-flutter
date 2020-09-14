import 'package:classeviva_lite/models/ClasseVivaAbsence.dart';
import 'package:classeviva_lite/models/ClasseVivaAgendaItem.dart';
import 'package:classeviva_lite/models/ClasseVivaCalendarLesson.dart';
import 'package:classeviva_lite/models/ClasseVivaGrade.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'ClasseVivaCalendar.g.dart';

@HiveType(typeId: 3)
class ClasseVivaCalendar
{
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final List<ClasseVivaGrade> grades;

  @HiveField(2)
  final List<ClasseVivaCalendarLesson> lessons;

  @HiveField(3)
  final List<ClasseVivaAgendaItem> agenda;

  final List<ClasseVivaAbsence> absences;

  ClasseVivaCalendar({
    @required this.date,
    @required this.grades,
    @required this.lessons,
    @required this.agenda,
    @required this.absences,
  });
}