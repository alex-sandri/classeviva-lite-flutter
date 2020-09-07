import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'ClasseVivaBasicProfile.dart';

@HiveType(typeId: 1)
class ClasseVivaProfile extends ClasseVivaBasicProfile
{
  @HiveField(0)
  final CircleAvatar profilePic;

  @HiveField(1)
  final CircleAvatar avatar;

  ClasseVivaProfile({
    @required name,
    @required school,
    @required this.profilePic,
    @required this.avatar,
  }): super(
    name: name,
    school: school,
  );
}