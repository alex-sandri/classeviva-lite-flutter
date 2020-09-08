import 'package:cache_image/cache_image.dart';
import 'package:classeviva_lite/models/ClasseVivaProfileAvatar.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'ClasseVivaProfile.g.dart';

@HiveType(typeId: 1)
class ClasseVivaProfile
{
  @HiveField(0)
  final String name;

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
  });

  Widget get profilePic => CircleAvatar(
    child: ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(50)),
      child: Image(
        image: CacheImage(profilePicUrl.toString()),
        height: 50,
      ),
    ),
    backgroundColor: Colors.white,
  );
}