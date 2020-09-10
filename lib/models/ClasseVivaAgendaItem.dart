import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

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
	final String data_inserimento;

  @HiveField(6)
	final String nota_2;

  @HiveField(7)
	final String master_id;

  @HiveField(8)
	final String classe_id;

  @HiveField(9)
	final String classe_desc;

  @HiveField(10)
	final int gruppo;

  @HiveField(11)
	final String autore_desc;

  @HiveField(12)
	final String autore_id;

  @HiveField(13)
	final String tipo;

  @HiveField(14)
	final String materia_desc;

  @HiveField(15)
	final String materia_id;

  ClasseVivaAgendaItem({
    @required this.id,
    @required this.title,
    @required this.start,
    @required this.end,
    @required this.allDay,
    @required this.data_inserimento,
    @required this.nota_2,
    @required this.master_id,
    @required this.classe_id,
    @required this.classe_desc,
    @required this.gruppo,
    @required this.autore_desc,
    @required this.autore_id,
    @required this.tipo,
    @required this.materia_desc,
    @required this.materia_id,
  });

  factory ClasseVivaAgendaItem.fromJson(Map<String, dynamic> json)
  {
    return ClasseVivaAgendaItem(
      id: json["id"],
      title: json["title"],
      start: DateTime.parse(json["start"]),
      end: DateTime.parse(json["end"]),
      allDay: json["allDay"],
      data_inserimento: json["data_inserimento"],
      nota_2: json["nota_2"],
      master_id: json["master_id"],
      classe_id: json["classe_id"],
      classe_desc: json["classe_desc"],
      gruppo: json["gruppo"],
      autore_desc: json["autore_desc"],
      autore_id: json["autore_id"],
      tipo: json["tipo"],
      materia_desc: json["materia_desc"],
      materia_id: json["materia_id"]
    );
  }
}