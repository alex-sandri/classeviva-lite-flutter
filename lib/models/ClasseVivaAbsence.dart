import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'ClasseVivaAbsence.g.dart';

@HiveType(typeId: 8)
class ClasseVivaAbsence
{
  @HiveField(0)
  final DateTime from;

  @HiveField(1)
  final DateTime to;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final ClasseVivaAbsenceType type;

  @HiveField(4)
  final ClasseVivaAbsenceStatus status;

  ClasseVivaAbsence({
    @required this.from,
    @required this.to,
    @required this.description,
    @required this.type,
    @required this.status,
  });
}

@HiveType(typeId: 9)
enum ClasseVivaAbsenceType
{
  @HiveField(0)
  Absence,

  @HiveField(1)
  Late,

  @HiveField(2)
  ShortDelay,

  @HiveField(3)
  EarlyExit,
}

@HiveType(typeId: 10)
enum ClasseVivaAbsenceStatus
{
  @HiveField(0)
  Justified,

  @HiveField(1)
  NotJustified,
}