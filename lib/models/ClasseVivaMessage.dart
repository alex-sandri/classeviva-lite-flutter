import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'ClasseVivaMessage.g.dart';

@HiveType(typeId: 22)
class ClasseVivaMessage
{
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subject;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final bool isRead;

  ClasseVivaMessage({
    @required this.id,
    @required this.subject,
    @required this.content,
    @required this.createdAt,
    @required this.isRead,
  });
}