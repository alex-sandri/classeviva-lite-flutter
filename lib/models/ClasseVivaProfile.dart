import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'ClasseVivaBasicProfile.dart';

part 'ClasseVivaProfile.g.dart';

@HiveType(typeId: 1)
class ClasseVivaProfile extends ClasseVivaBasicProfile
{
  @override
  @HiveField(0)
  final String name;

  @override
  @HiveField(1)
  final String school;

  final CircleAvatar profilePic;

  final CircleAvatar avatar;

  ClasseVivaProfile({
    @required this.name,
    @required this.school,
    @required this.profilePic,
    @required this.avatar,
  }): super(
    name: name,
    school: school,
  );
}