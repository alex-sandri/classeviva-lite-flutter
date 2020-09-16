import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'ClasseVivaFinalGrade.g.dart';

@HiveType(typeId: 20)
class ClasseVivaFinalGrade
{
  @HiveField(0)
  final String type;

  @HiveField(1)
  final String url;

  ClasseVivaFinalGrade({
    @required this.type,
    @required this.url,
  });
}