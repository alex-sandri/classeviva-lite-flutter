import 'dart:convert';
import 'dart:io';

import 'package:classeviva_lite/miscellaneous/cache_manager.dart';
import 'package:classeviva_lite/miscellaneous/http_manager.dart';
import 'package:classeviva_lite/models/ClasseVivaBasicProfile.dart';
import 'package:classeviva_lite/models/ClasseVivaProfile.dart';
import 'package:classeviva_lite/models/ClasseVivaProfileAvatar.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:hive/hive.dart';


class ClasseVivaEndpoints
{
  final String year;

  String baseUrl;

  ClasseVivaEndpoints(this.year) {
    baseUrl = "https://web$year.spaggiari.eu";
  }

  String auth() => "$baseUrl/auth-p7/app/default/AuthApi4.php?a=aLoginPwd";

	String basicProfile() => "$baseUrl/home/app/default/menu_webinfoschool_genitori.php";

  String profile() => "$baseUrl/acc/app/default/me.php";

	String grades() => "$baseUrl/cvv/app/default/genitori_note.php?filtro=tutto";

  String gradesWithPeriods() => "$baseUrl/cvv/app/default/genitori_voti.php";

  // Add timeZoneOffset hours to be in the UTC+0 TimeZone
	String agenda(DateTime start, DateTime end) =>
    "$baseUrl/fml/app/default/agenda_studenti.php?ope=get_events"
    + "&start="
    + (start.toUtc().add(start.timeZoneOffset).millisecondsSinceEpoch / 1000).truncate().toString()
    + "&end="
    + (end.toUtc().add(end.timeZoneOffset).millisecondsSinceEpoch / 1000).truncate().toString();

	String attachments(int page) => "$baseUrl/fml/app/default/didattica_genitori_new.php?p=$page";

	String fileAttachments(String id, String checksum) =>
		"$baseUrl/fml/app/default/didattica_genitori.php?a=downloadContenuto&contenuto_id=$id&cksum=$checksum";
  
	String textAttachments(String id) => "$baseUrl/fml/app/default/didattica.php?a=getContentText&contenuto_id=$id";

	String demerits() => "$baseUrl/fml/app/default/gioprof_note_studente.php";

  String absences() => "$baseUrl/tic/app/default/consultasingolo.php";

  String subjects() => "$baseUrl/fml/app/default/regclasse_lezioni_xstudenti.php";

  String lessons(String subjectId, List<String> teacherIds) => "$baseUrl/fml/app/default/regclasse_lezioni_xstudenti.php?action=loadLezioni&materia=$subjectId&autori_id=${teacherIds.join(",")}";

  String bulletinBoard(String query, bool hideInactive) => "$baseUrl/sif/app/default/bacheca_personale.php?action=get_comunicazioni&cerca=$query&ncna=${hideInactive ? "1" : "0"}";

  String bulletinBoardItemDetails(String id) => "$baseUrl/sif/app/default/bacheca_comunicazione.php?action=risposta_com&com_id=$id";

  String previousYear(String previousYear) => "$baseUrl/home/app/default/xasapi.php?a=lap&bu=https://web$previousYear.spaggiari.eu&ru=/home/&fu=xasapi-ERROR.php";

  String calendar(DateTime date) => "$baseUrl/cvv/app/default/regclasse.php?data_start=${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}";

  String finalGrades() => "$baseUrl/sol/app/default/documenti_sol.php";

  String books() => "$baseUrl/ldt/app/default/libri_studente.php";

  String virtualClassrooms() => "$baseUrl/cvp/app/default/sva_aule.php";

  String meetings() => "$baseUrl/fml/app/default/genitori_colloqui.php";

  String helpDesk() => "$baseUrl/fml/app/default/alunni_sportello.php";
}

class ClasseVivaSession
{
  String _id;
  final String year;
  final String uid;
  final String pwd;

  ClasseVivaSession({
    @required id,
    @required this.year,
    @required this.uid,
    @required this.pwd,
  })
  {
    _id = id;
  }

  String get id => _id;

  Future<void> refresh() async {
    final ClasseVivaSession refreshedSession = await ClasseVivaSession.create(
      uid: uid,
      pwd: pwd,
      year: year
    );

    final Box preferences = Hive.box("preferences");

    final ClasseVivaSession currentSession = ClasseViva.getCurrentSession();

    final List<ClasseVivaSession> sessions = ClasseViva.getAllSessions();

    sessions.firstWhere((session) => session.id == this.id)._id = refreshedSession.id;

    await preferences.put("sessions", sessions.map((session) => session.toString()).toList());

    if (currentSession?.id == this.id)
      await preferences.put("currentSession", refreshedSession.toString());

    _id = refreshedSession.id;
  }

  static Future<ClasseVivaSession> create({ String uid, String pwd, String year = "" }) async {
    final response = await http.post(
			ClasseVivaEndpoints(year).auth(),
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

    return ClasseVivaSession(
      id: sessionId,
      year: year,
      uid: uid,
      pwd: pwd,
    );
  }

  Future<void> signOut() async {
    final Box preferences = Hive.box("preferences");

    final ClasseVivaSession currentSession = ClasseViva.getCurrentSession();

    final List<ClasseVivaSession> sessions = ClasseViva.getAllSessions();

    sessions.removeWhere((session) => session.id == this.id);

    await preferences.put("sessions", sessions.map((session) => session.toString()).toList());

    if (currentSession?.id == this.id)
      await preferences.delete("currentSession");
  }

  @override
  String toString() => "$id;$uid;$pwd;$year";

  static ClasseVivaSession fromString(String session) => ClasseVivaSession(
    id: session.split(";").first,
    year: session.split(";").last,
    uid: session.split(";")[1],
    pwd: session.split(";")[2],
  );
}

class ClasseVivaGradesPeriod
{
	final String name;
  final List<ClasseVivaGrade> grades;

  ClasseVivaGradesPeriod({
    @required this.name,
    @required this.grades,
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

class ClasseVivaCalendarLesson
{
  final String teacher;
  final String subject;
  final String type;
  final String description;
  final int hour;
  final Duration duration;

  ClasseVivaCalendarLesson({
    @required this.teacher,
    @required this.subject,
    @required this.type,
    @required this.description,
    @required this.hour,
    @required this.duration,
  });
}

class ClasseVivaCalendar
{
  final DateTime date;
  final List<ClasseVivaGrade> grades;
  final List<ClasseVivaCalendarLesson> lessons;
  final List<ClasseVivaAgendaItem> agenda;

  ClasseVivaCalendar({
    @required this.date,
    @required this.grades,
    @required this.lessons,
    @required this.agenda,
  });
}

class ClasseVivaFinalGrade
{
  final String type;
  final Uri url;

  ClasseVivaFinalGrade({
    @required this.type,
    @required this.url,
  });
}

class ClasseVivaBook
{
  final String title;
  final String description;
  final List<String> categories;
  final String publisher;
  final String isbn;
  final double price;
  final bool mustBuy;
  final bool isInUse;
  final bool isSuggested;

  ClasseVivaBook({
    @required this.title,
    @required this.description,
    @required this.categories,
    @required this.publisher,
    @required this.isbn,
    @required this.price,
    @required this.mustBuy,
    @required this.isInUse,
    @required this.isSuggested,
  });
}

class ClasseViva
{
  static const Color PRIMARY_LIGHT = Color(0xffcc1020);

  int getYear() => session.year == ""
    ? DateTime.now().year
    : int.parse("20${session.year}");

  /// Use this for previous years websites.
  ///
  /// If we are in the current year and `ignoreCurrentYear` is `true`, an empty string is returned
  String getShortYear([ bool ignoreCurrentYear = true ]) =>
    session.year == "" && ignoreCurrentYear
      ? ""
      : getYear().toString().substring(2, 4);

  /// 1st of August of the session year
  DateTime yearBeginsAt;

  /// 31st of July of the year after the session year
  DateTime yearEndsAt;

  final ClasseVivaSession session;

  ClasseVivaEndpoints _endpoints;

  int attachmentsPage = 1;

	ClasseViva(this.session)
  {
    yearBeginsAt = DateTime(getYear(), 7, 1);

    yearEndsAt = DateTime(getYear() + 1, 6, 31);

    _endpoints = ClasseVivaEndpoints(session.year);
  }

  Map<String, String> getSessionCookieHeader() {
    return {
      "Cookie": "PHPSESSID=${session.id}",
    };
  }

  Future<void> checkValidSession() async {
    final result = await HttpManager.get(
      url: _endpoints.basicProfile(),
      headers: getSessionCookieHeader(),
    );

    if (result.isError) return;

    final document = parse(result.response.body);

    if (document.querySelector(".name") == null) await session.refresh();
  }

	Stream<ClasseVivaBasicProfile> getBasicProfile() async* {
    yield CacheManager.get("basicProfile");

    await checkValidSession();

		final result = await HttpManager.get(
      url: _endpoints.basicProfile(),
      headers: getSessionCookieHeader(),
    );

    if (result.isError) return;

    final document = parse(result.response.body);

    final ClasseVivaBasicProfile basicProfile = ClasseVivaBasicProfile(
      name: document.querySelector(".name").text.trim(),
			school: document.querySelector(".scuola").text.trim(),
    );

    await CacheManager.set("basicProfile", basicProfile);

		yield basicProfile;
	}

  Stream<ClasseVivaProfile> getProfile() async* {
    yield CacheManager.get("profile");

    await checkValidSession();

    Color _getColorFromHexString(String hex) {
      Color color;

      if (hex.length == 3) // Shorthand form
        color = Color(int.parse("FF${hex.replaceAllMapped(RegExp("."), (match) => match.group(0) * 2)}", radix: 16));
      else color = Color(int.parse("FF$hex", radix: 16));

      return color;
    }

    await for (ClasseVivaBasicProfile basicProfile in getBasicProfile())
    {
      if (basicProfile == null) continue;

      final result = await HttpManager.get(
        url: _endpoints.profile(),
        headers: getSessionCookieHeader(),
      );

      if (result.isError) return;

      final document = parse(result.response.body);

      final Uri profilePicUrl = Uri
        .parse(_endpoints.profile())
        .resolve(
          document.getElementById("top_page_foto_div").querySelector("img").attributes["src"]
        );

      final ClasseVivaProfile profile = ClasseVivaProfile(
        name: basicProfile.name,
        school: basicProfile.school,
        profilePicUrl: profilePicUrl.toString(),
        avatar: ClasseVivaProfileAvatar(
          text: document.querySelector(".iniziali_avatar").text.trim(),
          backgroundColor: _getColorFromHexString(document.querySelector(".iniziali_sfondo").attributes["value"].trim()),
          foregroundColor: _getColorFromHexString(document.querySelector(".iniziali_colore").attributes["value"].trim()),
        ),
      );

      await CacheManager.set("profile", profile);

      yield profile;
    }
	}

  Future<List<ClasseVivaGrade>> getGrades() async {
    await checkValidSession();

		final response = await http.get(
      _endpoints.grades(),
      headers: getSessionCookieHeader(),
    );

		final document = parse(response.body);

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

	Future<List<ClasseVivaGradesPeriod>> getPeriods() async {
    await checkValidSession();

		final response = await http.get(
      _endpoints.gradesWithPeriods(),
      headers: getSessionCookieHeader(),
    );

		final document = parse(response.body);

		List<ClasseVivaGradesPeriod> periods = [];

		document.querySelectorAll("#tabs a").forEach((tab) {
      final String periodId = tab.attributes["href"];

      final String periodName = tab.text.trim();

      List<ClasseVivaGrade> grades = [];

      document.querySelector(periodId).querySelectorAll(".riga_materia_componente").forEach((subject) {
        final String subjectName = subject.querySelector(".materia_desc").text.trim().toUpperCase();

        subject.querySelectorAll(".cella_voto").forEach((grade) {
          final String dateString = grade.querySelector(".voto_data").text.trim();

          final int year = int.parse(dateString.split("/").last.replaceAll(RegExp(r'^0+(?=.)'), "")) <= 8
            ? getYear() + 1
            : getYear();

          grades.add(ClasseVivaGrade(
            subject: subjectName,
            grade: grade.querySelector(".s_reg_testo").text.trim(),
            type: grade.querySelector(".s_reg_testo").parent.attributes["title"],
            description: "", // Not available with this method of retrieving them
            date: DateTime(
              year,
              int.parse(dateString.split("/").last),
              int.parse(dateString.split("/").first),
            ),
          ));
        });
      });

      periods.add(ClasseVivaGradesPeriod(
        name: periodName,
        grades: grades,
      ));
    });

		return periods;
	}

	Future<List<ClasseVivaAgendaItem>> getAgenda(DateTime start, DateTime end) async {
    await checkValidSession();

		final response = await http.get(
      _endpoints.agenda(start, end),
      headers: getSessionCookieHeader(),
    );

		return ((jsonDecode(response.body) ?? []) as List).map((item) => ClasseVivaAgendaItem.fromJson(item)).toList();
	}

	Future<List<ClasseVivaAttachment>> getAttachments() async {
    await checkValidSession();

		final response = await http.get(
      _endpoints.attachments(attachmentsPage),
      headers: getSessionCookieHeader(),
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
          url = Uri.parse(_endpoints.fileAttachments(id, attachment.querySelector(".button_action").attributes["cksum"]));
          break;
				case ClasseVivaAttachmentType.Link:
          url = Uri.parse(attachment.querySelector(".button_action").attributes["ref"]);
          break;
				case ClasseVivaAttachmentType.Text:
          url = Uri.parse(_endpoints.textAttachments(id));
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
    await checkValidSession();

		final response = await http.get(
			_endpoints.demerits(),
      headers: getSessionCookieHeader(),
    );

		final document = parse(response.body);

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
    await checkValidSession();

		final response = await http.get(
			_endpoints.absences(),
      headers: getSessionCookieHeader(),
    );

		final document = parse(response.body);

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
        final int year = getYear() + (fromMonthIndex <= 7 ? 1 : 0);

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

        final int year = getYear() + (monthIndex <= 7 ? 1 : 0);

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

        final int year = getYear() + (monthIndex <= 7 ? 1 : 0);

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
    await checkValidSession();

		final response = await http.get(
			_endpoints.subjects(),
      headers: getSessionCookieHeader(),
    );

		final document = parse(response.body);

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
    await checkValidSession();

		final response = await http.get(
			_endpoints.lessons(subject.id, subject.teacherIds),
      headers: getSessionCookieHeader(),
    );

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

  Future<List<ClasseVivaBulletinBoardItem>> getBulletinBoard({ String query = "", bool hideInactive = true }) async {
    await checkValidSession();

		final response = await http.get(
			_endpoints.bulletinBoard(query, hideInactive),
      headers: getSessionCookieHeader(),
    );

    final jsonResponse = jsonDecode("${response.body}");

    List responseItems = [];

    if (jsonResponse != null && !(jsonResponse is List))
    {
      if (jsonResponse["msg_new"] != null) responseItems.addAll(jsonResponse["msg_new"]);

      if (jsonResponse["read"] != null) responseItems.addAll(jsonResponse["read"]);
    }

    List<ClasseVivaBulletinBoardItem> items = responseItems.map((item) => ClasseVivaBulletinBoardItem.fromJson(item)).toList();

    items.sort((a, b) {
      // Most recent first
      return b.evento_data.compareTo(a.evento_data);
    });

		return items;
	}

  Future<ClasseVivaBulletinBoardItemDetails> getBulletinBoardItemDetails(String id) async {
    await checkValidSession();

		final response = await http.get(
			_endpoints.bulletinBoardItemDetails(id),
      headers: getSessionCookieHeader(),
    );

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

  Future<ClasseVivaCalendar> getCalendar(DateTime date) async {
    await checkValidSession();

		final response = await http.get(
			_endpoints.calendar(date),
      headers: getSessionCookieHeader(),
    );

    final document = parse(response.body);

    List<ClasseVivaCalendarLesson> lessons = [];

    document.querySelectorAll("#data_table").last.querySelectorAll(".rigtab").forEach((lesson) {
      if (lesson.querySelector(".registro_firma_dett_docente") == null
        || lesson.id != "") return;

      lessons.add(ClasseVivaCalendarLesson(
        teacher: lesson.querySelector(".registro_firma_dett_docente div:first-child").text.trim(),
        subject: lesson.querySelector(".registro_firma_dett_materia").attributes["title"],
        type: lesson.querySelector(".registro_firma_dett_argomento_nota").previousElementSibling.text.trim(),
        description: lesson.querySelector(".registro_firma_dett_argomento_nota").text.trim(),
        hour: int.parse(
          lesson
            .querySelector(".registro_firma_dett_ora")
            .text
            .split(" ")
            .first
            .replaceFirst("^", "")
        ),
        duration: Duration(
          hours: int.parse(
            lesson
              .querySelector(".registro_firma_dett_ora")
              .text
              .split(" ")
              .last
              .replaceFirst("(", "")
              .replaceFirst(")", "")
          ),
        ),
      ));
    });

    return ClasseVivaCalendar(
      date: date,
      grades: (await getGrades()).where((grade) => grade.date.isAtSameMomentAs(date)).toList(),
      lessons: lessons,
      agenda: (await getAgenda(date, DateTime(
        date.year,
        date.month,
        date.day,
        23, 59, 59,
      ))),
    );
	}

  Future<List<ClasseVivaFinalGrade>> getFinalGrades() async {
    await checkValidSession();

		final response = await http.get(
			_endpoints.finalGrades(),
      headers: getSessionCookieHeader(),
    );

    final document = parse(response.body);

    List<ClasseVivaFinalGrade> finalGrades = [];

    document.querySelector("#table_documenti").querySelectorAll(".rigtab").forEach((element) {
      finalGrades.add(ClasseVivaFinalGrade(
        type: element.querySelector(".align_middle").text.trim(),
        url: Uri.parse(_endpoints.baseUrl + element.querySelectorAll("td").last.querySelector("span").attributes["xhref"]),
      ));
    });

    return finalGrades;
	}

  Future<List<ClasseVivaBook>> getBooks() async {
    await checkValidSession();

		final response = await http.get(
			_endpoints.books(),
      headers: getSessionCookieHeader(),
    );

    final document = parse(response.body);

    List<ClasseVivaBook> books = [];

    document.querySelectorAll(".gen.ado").forEach((book) {
      final List<dom.Element> info = book.querySelector("[colspan=\"31\"]").querySelectorAll("p");

      final List<dom.Element> flags = book.querySelector("[colspan=\"7\"]").querySelectorAll("p");

      books.add(ClasseVivaBook(
        title: info.first.text.trim(),
        description: info[1].text.trim(),
        categories: info[2].text.split(",").map((category) => category.trim()).toList(),
        publisher: info[3].text.trim(),
        isbn: info.last.text.trim(),
        price: double.parse(book.querySelector("[colspan=\"6\"]").text.trim().split(" ").last.replaceFirst("€", "")),
        mustBuy: flags.first.text.trim().split(" ").last == "SI",
        isInUse: flags[1].text.trim().split(" ").last == "SI",
        isSuggested: flags.last.text.trim().split(" ").last == "SI",
      ));
    });

    return books;
	}

	static Future<ClasseViva> createSession(String uid, String pwd, { String year = "" }) async {
    final ClasseVivaSession session = await ClasseVivaSession.create(
      uid: uid,
      pwd: pwd,
      year: year
    );

    await ClasseViva.addSession(session);

    await ClasseViva.setCurrentSession(session);

		return ClasseViva(session);
	}

  static bool isSignedIn() => ClasseViva.getCurrentSession() != null;

  static Future<void> addSession(ClasseVivaSession session) async {
    final Box preferences = Hive.box("preferences");

    final List<ClasseVivaSession> sessions = ClasseViva.getAllSessions();

    sessions.add(session);

    await preferences.put("sessions", sessions.map((session) => session.toString()).toList());
  }

  static ClasseVivaSession getCurrentSession() {
    final Box preferences = Hive.box("preferences");

    final String session = preferences.get("currentSession");

    if (session == null) return null;

    return ClasseVivaSession.fromString(session);
  }

  static Future<void> setCurrentSession(ClasseVivaSession session) async {
    final Box preferences = Hive.box("preferences");

    await preferences.put("currentSession", session.toString());
  }

  static List<ClasseVivaSession> getAllSessions() {
		final Box preferences = Hive.box("preferences");

    final List<String> sessions = preferences.get("sessions");

    return sessions?.map((session) => ClasseVivaSession.fromString(session))?.toList() ?? [];
	}

  static double getGradeValue(String grade)
  {
    double value = double.tryParse(grade.replaceFirst(",", "."));

    // IMPORTANT: These are not accurate at all, I just guessed what their equivalents are (but they somehow seem reasonable)
    // I just incremented them by 0.25, except for the 'ns/s' which was incremented by 0.5
    Map<String, String> reGrades = {
      // Non sufficiente
      "ns": "5",
      // Insufficiente
      "i": "5",
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
      // Moltissimo?
      "ms": "9.5",
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
      else value = -1; // Grade value not yet supported
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

  static double getAverageGrade(List<ClasseVivaGrade> grades)
  {
    // Grades with "Voto Test" type can't be included in the average
    final List<ClasseVivaGrade> gradesValidForAverageCount = ClasseViva.getGradesValidForAverageCount(grades);

    if (gradesValidForAverageCount.length == 0) return -1;

    return gradesValidForAverageCount
      .map((grade) => ClasseViva.getGradeValue(grade.grade))
      .reduce((a, b) => a + b) / gradesValidForAverageCount.length;
  }

  static List<ClasseVivaGrade> getGradesValidForAverageCount(List<ClasseVivaGrade> grades)
  {
    return grades
      // Grades with "Voto Test" type can't be included in the average
      .where((grade) => grade.type != "Voto Test")
      .where((grade) {
        final bool isSupported = ClasseViva.getGradeValue(grade.grade) != -1;

        return isSupported;
      }).toList();
  }
}