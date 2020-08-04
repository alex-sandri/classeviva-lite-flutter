import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

class ClasseVivaEndpoints
{
  // TODO: Allow changing the year
	static String _year = "";

  static String auth() => "https://web${ClasseVivaEndpoints._year}.spaggiari.eu/auth-p7/app/default/AuthApi4.php?a=aLoginPwd";

	static String profile() => "https://web${ClasseVivaEndpoints._year}.spaggiari.eu/home/app/default/menu_webinfoschool_studenti.php";

	static String grades() => "https://web${ClasseVivaEndpoints._year}.spaggiari.eu/cvv/app/default/genitori_note.php?filtro=tutto";

	static String agenda() => "https://web${ClasseVivaEndpoints._year}.spaggiari.eu/fml/app/default/agenda_studenti.php?ope=get_events";

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
	String date;

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
	String note_2;
	String master_id;
	String classe_id;
	String classe_desc;
	String gruppo;
	String autore_desc;
	String autore_id;
	String tipo;
	String materia_desc;
	String materia_id;
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
  final String _sessionId;

	ClasseViva(this._sessionId);

  Map<String, String> _getSessionCookieHeader() {
    return {
      "Cookie": "PHPSESSID=$_sessionId",
    };
  }

	Future<ClasseVivaProfile> getProfile() async {
		final response = await http.get(
      ClasseVivaEndpoints.profile(),
      headers: _getSessionCookieHeader(),
    );

    final document = parse(response.body);

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

		List<ClasseVivaGrade> grades = [];

		document.querySelectorAll(".registro").forEach((element) {
			final subject = element.text.trim();

      dom.Element nextSibling = element.parent.nextElementSibling;

      while (nextSibling.attributes["align"] != "center")
      {
        final grade = nextSibling;

        grades.add(ClasseVivaGrade(
					subject: subject,
					grade: grade.querySelector(".s_reg_testo").text.trim(),
					type: grade.querySelectorAll(".voto_data").last.text.trim(),
					description: grade.querySelector("[colspan=32] span").text.trim(),
					date: grade.querySelectorAll(".voto_data").first.text.trim(),
        ));

        nextSibling = nextSibling.nextElementSibling;
      }
		});

		return grades;
	}

	Future<List<ClasseVivaAgendaItem>> getAgenda(DateTime start, DateTime end) async {
		final response = await http.post(
      ClasseVivaEndpoints.agenda(),
      headers: _getSessionCookieHeader(),
			body: {
				start: (start.millisecondsSinceEpoch / 1000).truncate(),
				end: (end.millisecondsSinceEpoch / 1000).truncate(),
			}.toString(),
    );

		return response.body as List<ClasseVivaAgendaItem>;
	}

	Future<List<ClasseVivaAttachment>> getAttachments() async {
		final response = await http.get(
      ClasseVivaEndpoints.attachments(),
      headers: _getSessionCookieHeader(),
    );

		final document = parse(response.body);

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

	static Future<ClasseViva> createSession(String uid, String pwd) async {
		final response = await http.post(
			ClasseVivaEndpoints.auth(),
      headers: {
				"Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
			},
			body: {
        "uid": uid,
        "pwd": pwd,
        "cid": "",
        "pin": "",
        "target": ""
      }.toString(),
		);

		final responseJson = jsonDecode(response.body);

		if ((responseJson["error"] as List<dynamic>).length > 0) return Future.error(responseJson["error"]);

    print(response.headers["set-cookie"]);

		final cookies = Cookie.fromSetCookieValue(response.headers["set-cookie"]).value;

		return ClasseViva(cookies);
	}
}