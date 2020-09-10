import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'ClasseVivaGrade.g.dart';

@HiveType(typeId: 4)
class ClasseVivaGrade
{
  @HiveField(0)
	final String subject;

  @HiveField(1)
	final String grade;

  @HiveField(2)
	final String type;

  @HiveField(3)
	final String description;

  @HiveField(4)
	final DateTime date;

  ClasseVivaGrade({
    @required this.subject,
    @required this.grade,
    @required this.type,
    @required this.description,
    @required this.date,
  });
}