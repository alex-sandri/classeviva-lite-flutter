import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'ClasseVivaSubject.g.dart';

@HiveType(typeId: 11)
class ClasseVivaSubject
{
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<String> teacherIds;

  ClasseVivaSubject({
    @required this.id,
    @required this.name,
    @required this.teacherIds,
  });
}