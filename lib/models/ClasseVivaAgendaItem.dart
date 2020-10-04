import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'ClasseVivaAgendaItem.g.dart';

@HiveType(typeId: 5)
class ClasseVivaAgendaItem
{
  @HiveField(0)
	final String id;

  @HiveField(1)
	final String title;

  @HiveField(2)
	final DateTime start;

  @HiveField(3)
	final DateTime end;

  @HiveField(4)
	final bool allDay;

  @HiveField(5)
	final DateTime addedDate;

  @HiveField(6)
	final String content;

  @HiveField(7)
	final String masterId;

  @HiveField(8)
	final String classId;

  @HiveField(9)
	final String classDescription;

  @HiveField(10)
	final int group;

  @HiveField(11)
	final String authorDescription;

  @HiveField(12)
	final String authorId;

  @HiveField(13)
	final String type;

  @HiveField(14)
	final String subjectDescription;

  @HiveField(15)
	final String subjectId;

  ClasseVivaAgendaItem({
    @required this.id,
    @required this.title,
    @required this.start,
    @required this.end,
    @required this.allDay,
    @required this.addedDate,
    @required this.content,
    @required this.masterId,
    @required this.classId,
    @required this.classDescription,
    @required this.group,
    @required this.authorDescription,
    @required this.authorId,
    @required this.type,
    @required this.subjectDescription,
    @required this.subjectId,
  });

  factory ClasseVivaAgendaItem.fromJson(Map<String, dynamic> json)
  {
    return ClasseVivaAgendaItem(
      id: json["id"],
      title: json["title"],
      start: DateTime.parse(json["start"]),
      end: DateTime.parse(json["end"]),
      allDay: json["allDay"],
      addedDate: DateFormat("dd-MM-yyyy HH:mm:ss").parse(json["data_inserimento"]),
      content: json["nota_2"],
      masterId: json["master_id"],
      classId: json["classe_id"],
      classDescription: json["classe_desc"],
      group: json["gruppo"],
      authorDescription: json["autore_desc"],
      authorId: json["autore_id"],
      type: json["tipo"],
      subjectDescription: json["materia_desc"],
      subjectId: json["materia_id"]
    );
  }
}