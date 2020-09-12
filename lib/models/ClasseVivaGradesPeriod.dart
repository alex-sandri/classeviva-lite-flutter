import 'package:classeviva_lite/models/ClasseVivaGrade.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'ClasseVivaGradesPeriod.g.dart';

@HiveType(typeId: 7)
class ClasseVivaGradesPeriod
{
  @HiveField(0)
	final String name;

  @HiveField(1)
  final List<ClasseVivaGrade> grades;

  ClasseVivaGradesPeriod({
    @required this.name,
    @required this.grades,
  });
}