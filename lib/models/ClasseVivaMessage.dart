import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/miscellaneous/http_manager.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:html/parser.dart';

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

  static ClasseVivaMessage fromJson(Map<String, dynamic> json) 
  {
    final rawContent = parse(json["testo"]).body;

    rawContent.querySelectorAll("*").forEach((element) => element.remove());

    return ClasseVivaMessage(
      id: json["msg_id"],
      subject: json["oggetto"],
      content: rawContent.text,
      createdAt: DateTime.parse(json["dinsert"]),
      isRead: json["read_status"] == "1",
    );
  }

  Future<void> markAsRead() => HttpManager.get(
    url: ClasseVivaEndpoints.current.messageMarkAsRead(id: id),
  );
}