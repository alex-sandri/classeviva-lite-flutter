import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'ClasseVivaAbsenceMonth.g.dart';

@HiveType(typeId: 21)
class ClasseVivaAbsenceMonth
{
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int presencesCount;

  @HiveField(2)
  final int absencesCount;

  @HiveField(3)
  final int delaysCount;

  @HiveField(4)
  final int exitsCount;

  ClasseVivaAbsenceMonth({
    @required this.name,
    @required this.presencesCount,
    @required this.absencesCount,
    @required this.delaysCount,
    @required this.exitsCount,
  });
}