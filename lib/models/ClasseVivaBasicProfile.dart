import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class ClasseVivaBasicProfile
{
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String school;

  ClasseVivaBasicProfile({
    @required this.name,
    @required this.school,
  });
}