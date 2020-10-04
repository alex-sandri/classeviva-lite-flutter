import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'ClasseVivaBulletinBoardItem.g.dart';

@HiveType(typeId: 17)
class ClasseVivaBulletinBoardItem
{
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String titolo;

  @HiveField(2)
  final String testo;

  @HiveField(3)
  final DateTime startDate;

  @HiveField(4)
  final DateTime endDate;

  @HiveField(5)
  final String type;

  @HiveField(6)
  final String typeDescription;

  @HiveField(7)
  final String fileName;

  @HiveField(8)
  final String requests;

  @HiveField(9)
  final String id_relazione;

  @HiveField(10)
  final bool isRead;

  @HiveField(11)
  final bool answerFlag;

  @HiveField(12)
  final String answerText;

  @HiveField(13)
  final String answerFile;

  @HiveField(14)
  final bool edited;

  @HiveField(15)
  final DateTime eventDate;

  ClasseVivaBulletinBoardItem({
    @required this.id,
    @required this.titolo,
    @required this.testo,
    @required this.startDate,
    @required this.endDate,
    @required this.type,
    @required this.typeDescription,
    @required this.fileName,
    @required this.requests,
    @required this.id_relazione,
    @required this.isRead,
    @required this.answerFlag,
    @required this.answerText,
    @required this.answerFile,
    @required this.edited,
    @required this.eventDate,
  });

  factory ClasseVivaBulletinBoardItem.fromJson(Map<String, dynamic> json)
  {
    final String startDateString = json["data_start"];
    final String endDateString = json["data_stop"];
    final String eventDateString = json["evento_data"];

    return ClasseVivaBulletinBoardItem(
      id: json["id"],
      titolo: json["titolo"],
      testo: json["testo"],
      startDate: DateFormat("dd-MM-yyyy").parse(startDateString),
      endDate: DateFormat("dd-MM-yyyy").parse(endDateString),
      type: json["tipo_com"],
      typeDescription: json["tipo_com_desc"],
      fileName: json["nome_file"],
      requests: json["richieste"],
      id_relazione: json["id_relazione"],
      isRead: json["conf_lettura"] == "letto",
      answerFlag: json["flag_risp"] == "1",
      answerText: json["testo_risp"],
      answerFile: json["file_risp"],
      edited: json["modificato"] == "1",
      eventDate: DateFormat("dd-MM-yyyy").parse(eventDateString),
    );
  }
}