import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'ClasseVivaBulletinBoardItemDetails.g.dart';

@HiveType(typeId: 18)
class ClasseVivaBulletinBoardItemDetails
{
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final List<ClasseVivaBulletinBoardItemDetailsAttachment> attachments;

  ClasseVivaBulletinBoardItemDetails({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.attachments,
  });
}

@HiveType(typeId: 19)
class ClasseVivaBulletinBoardItemDetailsAttachment
{
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  ClasseVivaBulletinBoardItemDetailsAttachment({
    @required this.id,
    @required this.name,
  });
}