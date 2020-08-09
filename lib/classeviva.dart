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
  static String auth() => "https://web${ClasseViva.year}.spaggiari.eu/auth-p7/app/default/AuthApi4.php?a=aLoginPwd";

	static String profile() => "https://web${ClasseViva.year}.spaggiari.eu/home/app/default/menu_webinfoschool_studenti.php";

  // TODO: Use this URL (https://web19.spaggiari.eu/cvv/app/default/genitori_voti.php)
	static String grades() => "https://web${ClasseViva.year}.spaggiari.eu/cvv/app/default/genitori_note.php?filtro=tutto";

  // Add timeZoneOffset hours to be in the UTC+0 TimeZone
	static String agenda(DateTime start, DateTime end) =>
    "https://web${ClasseViva.year}.spaggiari.eu/fml/app/default/agenda_studenti.php?ope=get_events"
    + "&start="
    + (start.toUtc().add(start.timeZoneOffset).millisecondsSinceEpoch / 1000).truncate().toString()
    + "&end="
    + (end.toUtc().add(end.timeZoneOffset).millisecondsSinceEpoch / 1000).truncate().toString();

	static String attachments(int page) => "https://web${ClasseViva.year}.spaggiari.eu/fml/app/default/didattica_genitori_new.php?p=$page";

	static String fileAttachments(String id, String checksum) =>
		"https://web${ClasseViva.year}.spaggiari.eu/fml/app/default/didattica_genitori.php?a=downloadContenuto&contenuto_id=$id&cksum=$checksum";
  
	static String textAttachments(String id) => "https://web${ClasseViva.year}.spaggiari.eu/fml/app/default/didattica.php?a=getContentText&contenuto_id=$id";

	static String demerits() => "https://web${ClasseViva.year}.spaggiari.eu/fml/app/default/gioprof_note_studente.php";

  static String absences() => "https://web${ClasseViva.year}.spaggiari.eu/tic/app/default/consultasingolo.php";

  static String subjects() => "https://web${ClasseViva.year}.spaggiari.eu/fml/app/default/regclasse_lezioni_xstudenti.php";

  static String lessons(String subjectId, List<String> teacherIds) => "https://web${ClasseViva.year}.spaggiari.eu/fml/app/default/regclasse_lezioni_xstudenti.php?action=loadLezioni&materia=$subjectId&autori_id=${teacherIds.join(",")}";

  static String bulletinBoard() => "https://web${ClasseViva.year}.spaggiari.eu/sif/app/default/bacheca_personale.php";

  static String bulletinBoardItemDetails(String id) => "https://web${ClasseViva.year}.spaggiari.eu/sif/app/default/bacheca_comunicazione.php?action=risposta_com&com_id=$id";
}

class ClasseVivaProfile
{
  final String name;
  final String school;

  ClasseVivaProfile({
    @required this.name,
    @required this.school,
  });
}

class ClasseVivaGrade
{
	final String subject;
	final String grade;
	final String type;
	final String description;
	final DateTime date;

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
	final String id;
	final String title;
	final DateTime start;
	final DateTime end;
	final bool allDay;
	final String data_inserimento;
	final String nota_2;
	final String master_id;
	final String classe_id;
	final String classe_desc;
	final int gruppo;
	final String autore_desc;
	final String autore_id;
	final String tipo;
	final String materia_desc;
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

enum ClasseVivaAttachmentType
{
  File,
  Link,
  Text,
}

class ClasseVivaAttachment
{
	final String id;
	final String teacher;
	final String name;
	final String folder;
	final ClasseVivaAttachmentType type;
	final DateTime date;
	final Uri url;

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
	final String teacher;
	final DateTime date;
	final String content;
	final String type;

  ClasseVivaDemerit({
    @required this.teacher,
    @required this.date,
    @required this.content,
    @required this.type,
  });
}

enum ClasseVivaAbsenceType
{
  Absence,
  Late,
  ShortDelay,
  EarlyExit,
}

enum ClasseVivaAbsenceStatus
{
  Justified,
  NotJustified,
}

class ClasseVivaAbsence
{
  final DateTime from;
  final DateTime to;
  final String description;
  final ClasseVivaAbsenceType type;
  final ClasseVivaAbsenceStatus status;

  ClasseVivaAbsence({
    @required this.from,
    @required this.to,
    @required this.description,
    @required this.type,
    @required this.status,
  });
}

class ClasseVivaSubject
{
  final String id;
  final String name;
  final List<String> teacherIds;

  ClasseVivaSubject({
    @required this.id,
    @required this.name,
    @required this.teacherIds,
  });
}

class ClasseVivaLesson
{
  final String teacher;
  final DateTime date;
  final String description;

  ClasseVivaLesson({
    @required this.teacher,
    @required this.date,
    @required this.description,
  });
}

class ClasseVivaBulletinBoardItem
{
  final String id;
  final String titolo;
  final String testo;
  final DateTime data_start;
  final DateTime data_stop;
  final String tipo_com;
  final String tipo_com_desc;
  final String nome_file;
  final String richieste;
  final String id_relazione;
  final bool conf_lettura;
  final bool flag_risp;
  final String testo_risp;
  final String file_risp;
  final bool modificato;
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
      data_start: DateTime(
        int.parse(startDateString.split("-").last),
        int.parse(startDateString.split("-")[1]),
        int.parse(startDateString.split("-").first),
      ),
      data_stop: DateTime(
        int.parse(endDateString.split("-").last),
        int.parse(endDateString.split("-")[1]),
        int.parse(endDateString.split("-").first),
      ),
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
      evento_data: DateTime(
        int.parse(eventDateString.split("-").last),
        int.parse(eventDateString.split("-")[1]),
        int.parse(eventDateString.split("-").first),
      ),
    );
  }
}

class ClasseVivaBulletinBoardItemDetailsAttachment
{
  final String id;
  final String name;

  ClasseVivaBulletinBoardItemDetailsAttachment({
    @required this.id,
    @required this.name,
  });
}

class ClasseVivaBulletinBoardItemDetails
{
  final String id;
  final String title;
  final String description;
  final List<ClasseVivaBulletinBoardItemDetailsAttachment> attachments;

  ClasseVivaBulletinBoardItemDetails({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.attachments,
  });
}

class ClasseViva
{
  // TODO: Allow changing the year
	static String year = "19";

  // 1st of August 20(year)
  static DateTime yearBeginsAt = DateTime(int.parse("20$year"), 7, 1);

  // 31st of July 20(year)
  static DateTime yearEndsAt = DateTime(int.parse("20${int.parse(year) + 1}"), 6, 31);

  final String sessionId;

  final BuildContext context;

  int attachmentsPage = 1;

	ClasseViva({
    @required this.sessionId,
    @required this.context,
  });

  Map<String, String> getSessionCookieHeader() {
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
      headers: getSessionCookieHeader(),
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
      headers: getSessionCookieHeader(),
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
      headers: getSessionCookieHeader(),
    );

    // TODO: Check valid session

		return ((jsonDecode(response.body) ?? []) as List).map((item) => ClasseVivaAgendaItem.fromJson(item)).toList();
	}

	Future<List<ClasseVivaAttachment>> getAttachments() async {
		final response = await http.get(
      ClasseVivaEndpoints.attachments(attachmentsPage),
      headers: getSessionCookieHeader(),
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

      const List<String> months = [
        "Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno", "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre"
      ];

      final String dateString = attachment
        .querySelector("[colspan=\"7\"] div")
        .text
        .trim()
        .split(",")
        .last
        .trim()
        .replaceAll(" ", "/")
        .replaceFirstMapped(RegExp(months.join("|")), (match) => (months.indexWhere((element) => element == match.group(0)) + 1).toString());

			attachments.add(ClasseVivaAttachment(
				id: id,
				teacher: attachment.querySelector(":nth-child(2) div").text.trim(),
				name: attachment.querySelector(".row_contenuto_desc").text.trim(),
				folder: attachment.querySelector(".row_contenuto_desc").nextElementSibling.nextElementSibling.querySelector("span").text.trim(),
				type: type,
				date: DateTime(
          int.parse(dateString.split("/").last),
          int.parse(dateString.split("/")[1]),
          int.parse(dateString.split("/").first),
        ),
				url: url,
      ));
		});

		return attachments;
	}

	Future<List<ClasseVivaDemerit>> getDemerits() async {
		final response = await http.get(
			ClasseVivaEndpoints.demerits(),
      headers: getSessionCookieHeader(),
    );

		final document = parse(response.body);

    checkValidSession(document);

		List<ClasseVivaDemerit> demerits = [];

		document.querySelectorAll("#sort_table tbody tr").forEach((demerit) {
      final String dateString = demerit.querySelector(":nth-child(3)").text.trim();

			demerits.add(ClasseVivaDemerit(
				teacher: demerit.querySelector(":first-child").text.trim(),
				date: DateTime(
          int.parse(dateString.split("-").last),
          int.parse(dateString.split("-")[1]),
          int.parse(dateString.split("-").first),
        ),
				content: demerit.querySelector(":nth-child(5)").text.trim(),
				type: demerit.querySelector(":last-child").text.trim(),
			));
		});

		return demerits;
	}

  Future<List<ClasseVivaAbsence>> getAbsences() async {
		final response = await http.get(
			ClasseVivaEndpoints.absences(),
      headers: getSessionCookieHeader(),
    );

		final document = parse(response.body);

    checkValidSession(document);

		List<ClasseVivaAbsence> absences = [];

    const List<String> months = [
      "gen", "feb", "mar", "apr", "mag", "giu", "lug", "ago", "set", "ott", "nov", "dic"
    ];

    int rowIndex = 0;

		document.querySelectorAll("#skeda_eventi tr[height=\"38\"]").skip(1).forEach((element) {
      final ClasseVivaAbsenceStatus absenceStatus = rowIndex == 0
        ? ClasseVivaAbsenceStatus.NotJustified
        : ClasseVivaAbsenceStatus.Justified;

      // Absence
      element.querySelector("td[colspan=\"15\"]").querySelectorAll(".rigtab").forEach((element) {
        if (element.querySelectorAll("td[colspan=\"4\"]").isEmpty) return;

        final String fromDateString = element.querySelectorAll("td[colspan=\"4\"]").first.querySelector("p:last-child").text.trim();
        final String toDateString = element.querySelectorAll("td[colspan=\"4\"]").last.querySelector("p:last-child").text.trim();

        final int fromMonthIndex = months.indexOf(fromDateString.split(" ").last);
        final int toMonthIndex = months.indexOf(toDateString.split(" ").last);

        // 7 -> ago
        final int year = int.parse("20${int.parse(ClasseViva.year) + (fromMonthIndex <= 7 ? 1 : 0)}");

        String description = "";

        if (element.nextElementSibling.attributes["height"] == "19")
          description = element.nextElementSibling.text.trim();

        absences.add(ClasseVivaAbsence(
          from: DateTime(
            year,
            fromMonthIndex + 1,
            // Remove leading zeros
            // Source: https://stackoverflow.com/a/61507499
            int.parse(fromDateString.split(" ").first.replaceAll(RegExp(r'^0+(?=.)'), "")),
          ),
          to: DateTime(
            year,
            toMonthIndex + 1,
            int.parse(toDateString.split(" ").first.replaceAll(RegExp(r'^0+(?=.)'), "")),
          ),
          description: description,
          type: ClasseVivaAbsenceType.Absence,
          status: absenceStatus,
        ));
      });

      // Late
      element.querySelectorAll("td[colspan=\"12\"]").first.querySelectorAll(".rigtab").forEach((element) {
        if (element.querySelector("td[colspan=\"6\"] p:last-child") == null) return;

        final String dateString = element.querySelector("td[colspan=\"6\"] p:last-child").text.trim();

        final int monthIndex = months.indexOf(dateString.split(" ").last);

        // 7 -> ago
        final int year = int.parse("20${int.parse(ClasseViva.year) + (monthIndex <= 7 ? 1 : 0)}");

        final DateTime date = DateTime(
          year,
          monthIndex + 1,
          int.parse(dateString.split(" ").first.replaceAll(RegExp(r'^0+(?=.)'), "")),
        );

        final bool isShortDelay = element.querySelector("td:nth-child(5) p:last-child").text.trim() == "breve";

        String description;

        if (element.nextElementSibling.querySelector("td[colspan=\"13\"]") != null)
          description = element.nextElementSibling.querySelector("td[colspan=\"13\"]").text.trim();

        absences.add(ClasseVivaAbsence(
          from: date,
          to: date,
          description: description,
          type: isShortDelay
            ? ClasseVivaAbsenceType.ShortDelay
            : ClasseVivaAbsenceType.Late,
          status: absenceStatus,
        ));
      });

      // Early Exit
      element.querySelectorAll("td[colspan=\"12\"]").last.querySelectorAll(".rigtab").forEach((element) {
        if (element.querySelector("td[colspan=\"6\"] p:last-child") == null) return;

        final String dateString = element.querySelector("td[colspan=\"6\"] p:last-child").text.trim();

        final int monthIndex = months.indexOf(dateString.split(" ").last);

        // 7 -> ago
        final int year = int.parse("20${int.parse(ClasseViva.year) + (monthIndex <= 7 ? 1 : 0)}");

        final DateTime date = DateTime(
          year,
          monthIndex + 1,
          int.parse(dateString.split(" ").first.replaceAll(RegExp(r'^0+(?=.)'), "")),
        );

        String description;

        if (element.nextElementSibling.querySelector("td[colspan=\"13\"]") != null)
          description = element.nextElementSibling.querySelector("td[colspan=\"13\"]").text.trim();

        absences.add(ClasseVivaAbsence(
          from: date,
          to: date,
          description: description,
          type: ClasseVivaAbsenceType.EarlyExit,
          status: absenceStatus,
        ));
      });

      rowIndex++;
    });

		return absences;
	}

  Future<List<ClasseVivaSubject>> getSubjects() async {
		final response = await http.get(
			ClasseVivaEndpoints.subjects(),
      headers: getSessionCookieHeader(),
    );

		final document = parse(response.body);

    checkValidSession(document);

		List<ClasseVivaSubject> subjects = [];

		document.querySelectorAll("#data_table .materia").forEach((subject) {
			subjects.add(ClasseVivaSubject(
				id: subject.attributes["materia_id"],
        name: subject.attributes["title"],
        teacherIds: subject.attributes["autori_id"].split(","),
			));
		});

		return subjects;
	}

  Future<List<ClasseVivaLesson>> getLessons(ClasseVivaSubject subject) async {
		final response = await http.get(
			ClasseVivaEndpoints.lessons(subject.id, subject.teacherIds),
      headers: getSessionCookieHeader(),
    );

    // TODO: Check valid session

		final document = parse('''
      <!DOCTYPE html>
      <html>
        <head>
        </head>
        <body>
          <table>
            <tbody>
            ${response.body}
            </tbody>
          </table>
        </body>
      </html>
    ''');

		List<ClasseVivaLesson> lessons = [];

		document.querySelectorAll("tr").forEach((lesson) {
      final String dateString = lesson.querySelector("td:nth-child(3)").text.trim();

			lessons.add(ClasseVivaLesson(
        teacher: lesson.querySelector("td:first-child").text.trim(),
        date: DateTime(
          int.parse(dateString.split("-").last),
          int.parse(dateString.split("-")[1]),
          int.parse(dateString.split("-").first),
        ),
        description: lesson.querySelector("td:nth-child(5)").text.trim(),
      ));
		});

		return lessons;
	}

  Future<List<ClasseVivaBulletinBoardItem>> getBulletinBoard() async {
		final response = await http.post(
			ClasseVivaEndpoints.bulletinBoard(),
      headers: getSessionCookieHeader(),
      body: Uri(queryParameters: {
        "action": "get_comunicazioni",
        "ncna": "0" // Nascondi Comunicazioni Non Attive
      }).queryParameters,
    );

		// TODO: Check valid session

    final jsonResponse = jsonDecode("${response.body}");

    List responseItems = [];

    if (jsonResponse != null)
    {
      if (jsonResponse["msg_new"] != null) responseItems.addAll(jsonResponse["msg_new"]);

      if (jsonResponse["read"] != null) responseItems.addAll(jsonResponse["read"]);
    }

		return responseItems.map((item) => ClasseVivaBulletinBoardItem.fromJson(item)).toList();
	}

  Future<ClasseVivaBulletinBoardItemDetails> getBulletinBoardItemDetails(String id) async {
		final response = await http.get(
			ClasseVivaEndpoints.bulletinBoardItemDetails(id),
      headers: getSessionCookieHeader(),
    );

		// TODO: Check valid session

    final document = parse('''
      <!DOCTYPE html>
      <html>
        <head>
        </head>
        <body>
          ${response.body}
        </body>
      </html>
    ''');

    return ClasseVivaBulletinBoardItemDetails(
      id: document.querySelector("[comunicazione_id]").attributes["comunicazione_id"],
      title: document.querySelector("div:first-child").text.trim(),
      description: document.querySelector(".comunicazione_testo").text.trim(),
      attachments: document.querySelectorAll("[allegato_id]").map((attachment) => ClasseVivaBulletinBoardItemDetailsAttachment(
        id: attachment.attributes["allegato_id"],
        name: attachment.text.trim(),
      )).toList(),
    );
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
		final String sessionId = Cookie.fromSetCookieValue(response.headers["set-cookie"].split(",").last).value;

    final SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.setString("sessionId", sessionId);

		return ClasseViva(
      sessionId: sessionId,
      context: context,
    );
	}

  static Future<List<ClasseViva>> getAllSessions(BuildContext context) async {
		final SharedPreferences preferences = await SharedPreferences.getInstance();

    final List<String> sessionIds = preferences.getStringList("sessions");

		List<ClasseViva> sessions;

    sessionIds.forEach((sessionId) {
      sessions.add(ClasseViva(
        sessionId: sessionId,
        context: context,
      ));
    });

    return sessions;
	}

  static double getGradeValue(String grade)
  {
    double value = double.tryParse(grade.replaceFirst(",", "."));

    // IMPORTANT: These are not accurate at all, I just guessed what their equivalents are (but they somehow seem reasonable)
    // I just incremented them by 0.25, except for the 'ns/s' which was incremented by 0.5
    Map<String, String> reGrades = {
      // Non sufficiente
      "ns": "5",
      // Non sufficiente/Sufficiente
      "ns/s": "5.5",
      // Quasi sufficiente
      "qs": "6-",
      // Sufficiente
      "s": "6",
      // Più che sufficiente
      "ps": "6+",
      // Sufficiente/Discreto
      "s/dc": "6.5",
      // Quasi discreto
      "qd": "7-",
      // Discreto
      "dc": "7",
      // Più che discreto
      "pdc": "7+",
      // Discreto/Buono
      "dc/b": "7.5",
      // Quasi buono
      "qb": "8-",
      // Buono
      "b": "8",
      // Più che buono
      "pb": "8+",
      // Buono/Distinto
      "b/d": "8.5",
      // Quasi distinto
      "qdn": "9-",
      // Molto?
      "m": "9",
      // Distinto
      "ds": "9",
      // Più che distinto
      "pdn": "9+",
      // Distinto/Ottimo
      "d/o": "9.5",
      // Quasi ottimo
      "qo": "10-",
      // Ottimo
      "o": "10",
    };

    if (grade.contains("½")) value = double.parse(grade.replaceFirst("½", ".5"));
    else if (grade.contains("+")) value = double.parse(grade.replaceFirst("+", ".25"));
    else if (grade.contains("-")) value = double.parse(grade.replaceFirst("-", ".75")) - 1;

    if (value == null)
    {
      if (RegExp("^${reGrades.keys.join("|")}\$").hasMatch(grade))
      {
        grade = reGrades[grade];

        value = getGradeValue(grade);
      }
      else if (RegExp("^([0-9])/([1-9]|10)\$").hasMatch(grade))
        value = double.parse(grade.split("/").first + ".9");
    }

    return value;
  }

  static Color getGradeColor(ClasseVivaGrade grade)
  {
    Color color;

    double value = getGradeValue(grade.grade);

    if (grade.type != "Voto Test")
    {
      if (value == null) color = Colors.blue;
      else if (value >= 6) color = Colors.green;
      else if (value >= 5) color = Colors.orange;
      else color = Colors.red;
    }
    else color = Colors.blue;

    return color;
  }
}