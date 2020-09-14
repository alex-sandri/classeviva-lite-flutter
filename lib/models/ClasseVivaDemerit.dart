import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'ClasseVivaDemerit.g.dart';

@HiveType(typeId: 13)
class ClasseVivaDemerit
{
  @HiveField(0)
	final String teacher;

  @HiveField(1)
	final DateTime date;

  @HiveField(2)
	final String content;

  @HiveField(3)
	final String type;

  ClasseVivaDemerit({
    @required this.teacher,
    @required this.date,
    @required this.content,
    @required this.type,
  });
}