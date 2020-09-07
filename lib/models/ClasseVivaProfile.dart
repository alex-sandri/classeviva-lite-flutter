import 'package:classeviva_lite/models/ClasseVivaProfileAvatar.dart';
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

  @HiveField(2)
  final String profilePicUrl;

  @HiveField(3)
  final ClasseVivaProfileAvatar avatar;

  ClasseVivaProfile({
    @required this.name,
    @required this.school,
    @required this.profilePicUrl,
    @required this.avatar,
  }): super(
    name: name,
    school: school,
  );

  Widget get profilePic => CircleAvatar(
    child: ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(50)),
      child: Image.network(
        profilePicUrl.toString(),
        height: 50,
      ),
    ),
    backgroundColor: Colors.white,
  );
}