import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'ClasseVivaAttachment.g.dart';

@HiveType(typeId: 15)
class ClasseVivaAttachment
{
  @HiveField(0)
	final String id;

  @HiveField(1)
	final String teacher;

  @HiveField(2)
	final String name;

  @HiveField(3)
	final String folder;

  @HiveField(4)
	final ClasseVivaAttachmentType type;

  @HiveField(5)
	final DateTime date;

  @HiveField(6)
	final Uri url;

  ClasseVivaAttachment({
    @required this.id,
    @required this.teacher,
    @required this.name,
    @required this.folder,
    @required this.type,
    @required this.date,
    @required this.url,
  });
}

@HiveType(typeId: 16)
enum ClasseVivaAttachmentType
{
  @HiveField(0)
  File,

  @HiveField(1)
  Link,

  @HiveField(2)
  Text,
}