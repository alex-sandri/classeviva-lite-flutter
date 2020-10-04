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
  final DateTime data_start;

  @HiveField(4)
  final DateTime data_stop;

  @HiveField(5)
  final String tipo_com;

  @HiveField(6)
  final String tipo_com_desc;

  @HiveField(7)
  final String nome_file;

  @HiveField(8)
  final String richieste;

  @HiveField(9)
  final String id_relazione;

  @HiveField(10)
  final bool conf_lettura;

  @HiveField(11)
  final bool flag_risp;

  @HiveField(12)
  final String testo_risp;

  @HiveField(13)
  final String file_risp;

  @HiveField(14)
  final bool modificato;

  @HiveField(15)
  final DateTime evento_data;

  ClasseVivaBulletinBoardItem({
    @required this.id,
    @required this.titolo,
    @required this.testo,
    @required this.data_start,
    @required this.data_stop,
    @required this.tipo_com,
    @required this.tipo_com_desc,
    @required this.nome_file,
    @required this.richieste,
    @required this.id_relazione,
    @required this.conf_lettura,
    @required this.flag_risp,
    @required this.testo_risp,
    @required this.file_risp,
    @required this.modificato,
    @required this.evento_data,
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
      data_start: DateFormat("dd-MM-yyyy").parse(startDateString),
      data_stop: DateFormat("dd-MM-yyyy").parse(endDateString),
      tipo_com: json["tipo_com"],
      tipo_com_desc: json["tipo_com_desc"],
      nome_file: json["nome_file"],
      richieste: json["richieste"],
      id_relazione: json["id_relazione"],
      conf_lettura: json["conf_lettura"] == "letto",
      flag_risp: json["flag_risp"] == "1",
      testo_risp: json["testo_risp"],
      file_risp: json["file_risp"],
      modificato: json["modificato"] == "1",
      evento_data: DateFormat("dd-MM-yyyy").parse(eventDateString),
    );
  }
}