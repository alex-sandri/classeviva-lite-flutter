import 'dart:convert';
import 'dart:io';

import 'package:classeviva_lite/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClasseVivaEndpoints
{
  // TODO: Allow changing the year
	static String _year = "19";

  static String auth() => "https://web${ClasseVivaEndpoints._year}.spaggiari.eu/auth-p7/app/default/AuthApi4.php?a=aLoginPwd";

	static String profile() => "https://web${ClasseVivaEndpoints._year}.spaggiari.eu/home/app/default/menu_webinfoschool_studenti.php";

	static String grades() => "https://web${ClasseVivaEndpoints._year}.spaggiari.eu/cvv/app/default/genitori_note.php?filtro=tutto";

	static String agenda(DateTime start, DateTime end) =>
    "https://web${ClasseVivaEndpoints._year}.spaggiari.eu/fml/app/default/agenda_studenti.php?ope=get_events&start=${(start.millisecondsSinceEpoch / 1000).truncate()}&end=${(end.millisecondsSinceEpoch / 1000).truncate().toString()}";

	static String attachments() => "https://web${ClasseVivaEndpoints._year}.spaggiari.eu/fml/app/default/didattica_genitori_new.php";

	static String fileAttachments(String id, String checksum) =>
		"https://web${ClasseVivaEndpoints._year}.spaggiari.eu/fml/app/default/didattica_genitori.php?a=downloadContenuto&contenuto_id=$id&cksum=$checksum";
  
	static String textAttachments(String id) => "https://web${ClasseVivaEndpoints._year}.spaggiari.eu/fml/app/default/didattica.php?a=getContentText&contenuto_id=$id";

	static String demerits() => "https://web${ClasseVivaEndpoints._year}.spaggiari.eu/fml/app/default/gioprof_note_studente.php";
}

class ClasseVivaProfile
{
  String name;
  String school;

  ClasseVivaProfile({
    @required this.name,
    @required this.school,
  });
}

class ClasseVivaGrade
{
	String subject;
	String grade;
	String type;
	String description;
	DateTime date;

  ClasseVivaGrade({
    @required this.subject,
    @required this.grade,
    @required this.type,
    @required this.description,
    @required this.date,
  });
}

class ClasseVivaAgendaItem
{
	String id;
	String title;
	String start;
	String end;
	bool allDay;
	String data_inserimento;
	String nota_2;
	String master_id;
	String classe_id;
	String classe_desc;
	int gruppo;
	String autore_desc;
	String autore_id;
	String tipo;
	String materia_desc;
	String materia_id;

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
      start: json["start"],
      end: json["end"],
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

enum ClasseVivaAttachmentType
{
  File,
  Link,
  Text,
}

class ClasseVivaAttachment
{
	String id;
	String teacher;
	String name;
	String folder;
	ClasseVivaAttachmentType type;
	String date;
	Uri url;

  ClasseVivaAttachment({
    @required this.id,
    @required this.teacher,
    @required this.name,
    @required this.folder,
    @required this.type,
    @required this.date,
    @required this.url,
  });
}

class ClasseVivaDemerit
{
	String teacher;
	String date;
	String content;
	String type;

  ClasseVivaDemerit({
    @required this.teacher,
    @required this.date,
    @required this.content,
    @required this.type,
  });
}

class ClasseViva
{
  final String sessionId;

  final BuildContext context;

	ClasseViva({
    @required this.sessionId,
    @required this.context,
  });

  Map<String, String> _getSessionCookieHeader() {
    return {
      "Cookie": "PHPSESSID=$sessionId",
    };
  }

  Future<void> checkValidSession(dom.Document document) async {
    if (document.querySelector(".name") == null)
    {
      final SharedPreferences preferences = await SharedPreferences.getInstance();

      await preferences.remove("sessionId");

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => SignIn(),
        ),
        (route) => false,
      );
    }
  }

	Future<ClasseVivaProfile> getProfile() async {
		final response = await http.get(
      ClasseVivaEndpoints.profile(),
      headers: _getSessionCookieHeader(),
    );

    final document = parse(response.body);

    checkValidSession(document);

		return ClasseVivaProfile(
      name: document.querySelector(".name").text.trim(),
			school: document.querySelector(".scuola").text.trim(),
    );
	}

	Future<List<ClasseVivaGrade>> getGrades() async {
		final response = await http.get(
      ClasseVivaEndpoints.grades(),
      headers: _getSessionCookieHeader(),
    );

		final document = parse(response.body);

    checkValidSession(document);

		List<ClasseVivaGrade> grades = [];

		document.querySelectorAll(".registro").forEach((element) {
			final subject = element.text.trim();

      dom.Element nextSibling = element.parent.nextElementSibling;

      while (nextSibling != null && nextSibling.attributes["align"] != "center")
      {
        final grade = nextSibling;

        final String dateString = grade.querySelectorAll(".voto_data").first.text.trim();

        grades.add(ClasseVivaGrade(
					subject: subject,
					grade: grade.querySelector(".s_reg_testo").text.trim(),
					type: grade.querySelectorAll(".voto_data").last.text.trim(),
					description: grade.querySelector("[colspan=\"32\"] span").text.trim(),
					date: DateTime(
            int.parse(dateString.split("/").last),
            int.parse(dateString.split("/")[1]),
            int.parse(dateString.split("/").first),
          ),
        ));

        nextSibling = nextSibling.nextElementSibling;
      }
		});

		return grades;
	}

	Future<List<ClasseVivaAgendaItem>> getAgenda(DateTime start, DateTime end) async {
		final response = await http.get(
      ClasseVivaEndpoints.agenda(start, end),
      headers: _getSessionCookieHeader(),
    );

    // TODO: Check valid session

		return (jsonDecode(response.body) as List).map((e) => ClasseVivaAgendaItem.fromJson(e)).toList();
	}

	Future<List<ClasseVivaAttachment>> getAttachments() async {
		final response = await http.get(
      ClasseVivaEndpoints.attachments(),
      headers: _getSessionCookieHeader(),
    );

		final document = parse(response.body);

    checkValidSession(document);

		List<ClasseVivaAttachment> attachments = [];

		document.querySelectorAll(".contenuto").forEach((attachment) {
			final id = attachment.attributes["contenuto_id"];

			ClasseVivaAttachmentType type;
			Uri url;

      switch(attachment.querySelector("img").attributes["src"].split("/").last.split(".").first)
      {
        case "file": type = ClasseVivaAttachmentType.File; break;
        case "link": type = ClasseVivaAttachmentType.Link; break;
        case "testo": type = ClasseVivaAttachmentType.Text; break;
      }

			switch (type)
			{
				case ClasseVivaAttachmentType.File:
          url = Uri.parse(ClasseVivaEndpoints.fileAttachments(id, attachment.querySelector(".button_action").attributes["cksum"]));
          break;
				case ClasseVivaAttachmentType.Link:
          url = Uri.parse(attachment.querySelector(".button_action").attributes["ref"]);
          break;
				case ClasseVivaAttachmentType.Text:
          url = Uri.parse(ClasseVivaEndpoints.textAttachments(id));
          break;
			}

			attachments.add(ClasseVivaAttachment(
				id: id,
				teacher: attachment.querySelector(":nth-child(2)").text.trim(),
				name: attachment.querySelector(".row_contenuto_desc").text.trim(),
				folder: attachment.querySelector(".row_contenuto_desc + span span").text.trim(),
				type: type,
				date: attachment.querySelector("[colspan=7] div").text.trim(),
				url: url,
      ));
		});

		return attachments;
	}

	Future<List<ClasseVivaDemerit>> getDemerits() async {
		final response = await http.get(
			ClasseVivaEndpoints.demerits(),
      headers: _getSessionCookieHeader(),
    );

		final document = parse(response.body);

    checkValidSession(document);

		List<ClasseVivaDemerit> demerits = [];

		document.querySelectorAll("#sort_table tbody tr").forEach((demerit) {
			demerits.add(ClasseVivaDemerit(
				teacher: demerit.querySelector(":first-child").text.trim(),
				date: demerit.querySelector(":nth-child(2)").text.trim(),
				content: demerit.querySelector(":nth-child(3)").text.trim(),
				type: demerit.querySelector(":last-child").text.trim(),
			));
		});

		return demerits;
	}

	static Future<ClasseViva> createSession(String uid, String pwd, BuildContext context) async {
		final response = await http.post(
			ClasseVivaEndpoints.auth(),
      headers: {
				"Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
			},
			body: Uri(queryParameters: {
        "uid": uid,
        "pwd": pwd,
        "cid": "",
        "pin": "",
        "target": ""
      }).query,
		);

		final responseJson = jsonDecode(response.body);

    if (((responseJson["data"]["auth"]["errors"] ?? []) as List<dynamic>).length > 0) return Future.error(responseJson["data"]["auth"]["errors"]);

		if (((responseJson["error"] ?? []) as List<dynamic>).length > 0) return Future.error(responseJson["error"]);

    // Use the second PHPSESSID cookie (because for some reason ClasseViva returns two PHPSESSID cookies)
		final cookies = Cookie.fromSetCookieValue(response.headers["set-cookie"].split(",").last).value;

		return ClasseViva(
      sessionId: cookies,
      context: context,
    );
	}
}