import 'dart:convert';
import 'dart:io';

import 'package:classeviva_lite/miscellaneous/PreferencesManager.dart';
import 'package:classeviva_lite/miscellaneous/cache_manager.dart';
import 'package:classeviva_lite/miscellaneous/http_manager.dart';
import 'package:classeviva_lite/models/ClasseVivaAbsence.dart';
import 'package:classeviva_lite/models/ClasseVivaAbsenceMonth.dart';
import 'package:classeviva_lite/models/ClasseVivaAgendaItem.dart';
import 'package:classeviva_lite/models/ClasseVivaAttachment.dart';
import 'package:classeviva_lite/models/ClasseVivaBasicProfile.dart';
import 'package:classeviva_lite/models/ClasseVivaBook.dart';
import 'package:classeviva_lite/models/ClasseVivaBulletinBoardItem.dart';
import 'package:classeviva_lite/models/ClasseVivaBulletinBoardItemDetails.dart';
import 'package:classeviva_lite/models/ClasseVivaCalendar.dart';
import 'package:classeviva_lite/models/ClasseVivaCalendarLesson.dart';
import 'package:classeviva_lite/models/ClasseVivaDemerit.dart';
import 'package:classeviva_lite/models/ClasseVivaFinalGrade.dart';
import 'package:classeviva_lite/models/ClasseVivaGrade.dart';
import 'package:classeviva_lite/models/ClasseVivaGradesPeriod.dart';
import 'package:classeviva_lite/models/ClasseVivaLesson.dart';
import 'package:classeviva_lite/models/ClasseVivaMessage.dart';
import 'package:classeviva_lite/models/ClasseVivaProfile.dart';
import 'package:classeviva_lite/models/ClasseVivaProfileAvatar.dart';
import 'package:classeviva_lite/models/ClasseVivaSubject.dart';
import 'package:classeviva_lite/routes/SignIn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';


class ClasseVivaEndpoints
{
  final String year;

  String baseUrl;

  ClasseVivaEndpoints(this.year) {
    baseUrl = "https://web$year.spaggiari.eu";
  }

  static ClasseVivaEndpoints get current => ClasseViva(ClasseViva.getCurrentSession())._endpoints;

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

	String attachments() => "$baseUrl/fml/app/default/didattica_genitori.php";

	String fileAttachments(String id, String checksum) =>
		"$baseUrl/fml/app/default/didattica_genitori.php?a=downloadContenuto&contenuto_id=$id&cksum=$checksum";
  
	String textAttachments(String id) => "$baseUrl/fml/app/default/didattica.php?a=getContentText&contenuto_id=$id";

	String demerits() => "$baseUrl/fml/app/default/gioprof_note_studente.php";

  String absences() => "$baseUrl/tic/app/default/consultasingolo.php";

  String subjects() => "$baseUrl/fml/app/default/regclasse_lezioni_xstudenti.php";

  String lessons(String subjectId, List<String> teacherIds) => "$baseUrl/fml/app/default/regclasse_lezioni_xstudenti.php?action=loadLezioni&materia=$subjectId&autori_id=${teacherIds.join(",")}";

  String bulletinBoard(bool hideInactive) => "$baseUrl/sif/app/default/bacheca_personale.php?action=get_comunicazioni&ncna=${hideInactive ? "1" : "0"}";

  String bulletinBoardItemDetails(String id) => "$baseUrl/sif/app/default/bacheca_comunicazione.php?action=risposta_com&com_id=$id";

  String previousYear(String previousYear) => "$baseUrl/home/app/default/xasapi.php?a=lap&bu=https://web$previousYear.spaggiari.eu&ru=/home/&fu=xasapi-ERROR.php";

  String calendar(DateTime date) => "$baseUrl/cvv/app/default/regclasse.php?data_start=${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}";

  String finalGrades() => "$baseUrl/sol/app/default/documenti_sol.php";

  String books() => "$baseUrl/ldt/app/default/libri_studente.php";

  String virtualClassrooms() => "$baseUrl/cvp/app/default/sva_aule.php";

  String meetings() => "$baseUrl/fml/app/default/genitori_colloqui.php";

  String helpDesk() => "$baseUrl/fml/app/default/alunni_sportello.php";

  String homework() => "$baseUrl/fml/app/default/regdidattica_studenti_compito.php";

  String payments() => "$baseUrl/pfo/app/default/scadenze.php";

  String messages({ @required int messagesPerPage }) => "$baseUrl/sps/app/default/SocMsgApi.php?a=acGetMsgPag&mpp=$messagesPerPage";

  String messageMarkAsRead({ @required String id }) => "$baseUrl/sps/app/default/SocMsgApi.php?a=acSetDRead&mids%5B%5D=$id";
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
    await ClasseVivaSession.create(
      uid: uid,
      pwd: pwd,
      year: year
    ).then((refreshedSession) async {
      final ClasseVivaSession currentSession = ClasseViva.getCurrentSession();

      final List<ClasseVivaSession> sessions = ClasseViva.getAllSessions();

      sessions.firstWhere((session) => session.id == this.id)?._id = refreshedSession.id;

      await PreferencesManager.set("sessions", sessions.map((session) => session.toString()).toList());

      if (currentSession?.id == this.id)
        await ClasseViva.setCurrentSession(refreshedSession);

      _id = refreshedSession.id;
    },
    onError: (error) async {
      await signOut();

      Get.offAll(SignIn());
    });
  }

  static Future<ClasseVivaSession> create({ String uid, String pwd, String year = "" }) async {
    final response = await http.post(
			Uri.parse(ClasseVivaEndpoints(year).auth()),
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
    final ClasseVivaSession currentSession = ClasseViva.getCurrentSession();

    final List<ClasseVivaSession> sessions = ClasseViva.getAllSessions();

    sessions.removeWhere((session) => session.id == this.id);

    await PreferencesManager.set("sessions", sessions.map((session) => session.toString()).toList());

    if (currentSession?.id == this.id)
      await PreferencesManager.delete("currentSession");
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

class ClasseViva
{
  static const Color PRIMARY_LIGHT = Color(0xffcc1020);

  int getYear() {
    if (session.year.isNotEmpty) return int.parse("20${session.year}");

    final int currentMonth = DateTime.now().month;

    if (currentMonth >= 8 && currentMonth <= 12) return DateTime.now().year;

    return DateTime.now().year - 1;
  }

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

	ClasseViva(this.session)
  {
    yearBeginsAt = DateTime(getYear(), 8, 1);

    yearEndsAt = DateTime(getYear() + 1, 7, 31);

    _endpoints = ClasseVivaEndpoints(session.year);
  }

  static ClasseViva get current => ClasseViva(ClasseViva.getCurrentSession());

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
    yield CacheManager.get("basicProfile-${session.id}");

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

    await CacheManager.set("basicProfile-${session.id}", basicProfile);

		yield basicProfile;
	}

  Stream<ClasseVivaProfile> getProfile() async* {
    yield CacheManager.get("profile-${session.id}");

    await checkValidSession();

    Color _getColorFromHexString(String hex) {
      Color color;

      if (hex.length == 3) // Shorthand form
        color = Color(int.parse("FF${hex.replaceAllMapped(RegExp("."), (match) => match.group(0) * 2)}", radix: 16));
      else color = Color(int.parse("FF$hex", radix: 16));

      return color;
    }

    await for (final ClasseVivaBasicProfile basicProfile in getBasicProfile())
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

      await CacheManager.set("profile-${session.id}", profile);

      yield profile;
    }
	}

  Stream<List<ClasseVivaGrade>> getGrades() async* {
    yield (CacheManager.get("grades") as List<dynamic>)?.whereType<ClasseVivaGrade>()?.toList();

    await checkValidSession();

		final result = await HttpManager.get(
      url: _endpoints.grades(),
      headers: getSessionCookieHeader(),
    );

		if (result.isError) return;

    final document = parse(result.response.body);

		List<ClasseVivaGrade> grades = [];

		document.querySelectorAll(".registro").forEach((element) {
			final subject = element.text.trim();

      dom.Element nextSibling = element.parent.nextElementSibling;

      while (nextSibling != null && nextSibling.attributes["align"] != "center")
      {
        final grade = nextSibling;

        grades.add(ClasseVivaGrade(
					subject: subject,
					grade: grade.querySelector(".s_reg_testo").text.trim(),
					type: grade.querySelectorAll(".voto_data").last.text.trim(),
					description: (grade.querySelector("[colspan=\"33\"] span") ?? grade.querySelector("[colspan=\"32\"] span")).text.trim(),
					date: DateFormat("dd/MM/yyyy").parse(grade.querySelectorAll(".voto_data").first.text.trim()),
        ));

        nextSibling = nextSibling.nextElementSibling;
      }
		});

    grades.sort((a, b) {
      // Most recent first
      return b.date.compareTo(a.date);
    });

    await CacheManager.set("grades", grades);

		yield grades;
	}

	Stream<List<ClasseVivaGradesPeriod>> getPeriods() async* {
    yield (CacheManager.get("gradesWithPeriods") as List<dynamic>)?.whereType<ClasseVivaGradesPeriod>()?.toList();

    await checkValidSession();

		final result = await HttpManager.get(
      url: _endpoints.gradesWithPeriods(),
      headers: getSessionCookieHeader(),
    );

		if (result.isError) return;

    final document = parse(result.response.body);

		List<ClasseVivaGradesPeriod> periods = [];

		document.querySelectorAll("#tabs a").forEach((tab) {
      final String periodId = tab.attributes["href"];

      final String periodName = tab.text.trim();

      List<ClasseVivaGrade> grades = [];

      document.querySelector(periodId).querySelectorAll(".riga_materia_componente").forEach((subject) {
        final String subjectName = subject.querySelector(".materia_desc").text.trim().toUpperCase();

        subject.querySelectorAll(".cella_voto").forEach((grade) {
          final String dateString = grade.querySelector(".voto_data").text.trim();

          if (dateString.isEmpty) return;

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

      grades.sort((a, b) {
        // Most recent first
        return b.date.compareTo(a.date);
      });

      periods.add(ClasseVivaGradesPeriod(
        name: periodName,
        grades: grades,
      ));
    });

    await CacheManager.set("gradesWithPeriods", periods);

		yield periods;
	}

	Stream<List<ClasseVivaAgendaItem>> getAgenda(DateTime start, DateTime end, { String query = "", }) async* {
    List<ClasseVivaAgendaItem> _search(List<ClasseVivaAgendaItem> items, String query) =>
      items
        ?.where((item) =>
          item
          .content
          .toLowerCase()
          .contains(query.toLowerCase())
        )
        ?.toList();

    List<ClasseVivaAgendaItem> _getItemsInsideDateRange(List<ClasseVivaAgendaItem> items) =>
      items?.where((item) => item.start.isAfter(start) && item.end.isBefore(end))?.toList(); 

    yield _search(_getItemsInsideDateRange((CacheManager.get("agenda") as List<dynamic>)?.whereType<ClasseVivaAgendaItem>()?.toList()), query);

    await checkValidSession();

		final result = await HttpManager.get(
      url: _endpoints.agenda(yearBeginsAt, yearEndsAt),
      headers: getSessionCookieHeader(),
    );

    if (result.isError) return;

    final List<ClasseVivaAgendaItem> agenda = ((jsonDecode(result.response.body) ?? []) as List).map((item) => ClasseVivaAgendaItem.fromJson(item)).toList();

    agenda.sort((a, b) {
      // Most recent first
      return b.start.compareTo(a.start);
    });

    await CacheManager.set("agenda", agenda);

		yield _search(_getItemsInsideDateRange(agenda), query);
	}

	Stream<List<ClasseVivaAttachment>> getAttachments({ String query = "" }) async* {
    List<ClasseVivaAttachment> _search(List<ClasseVivaAttachment> items, String query) =>
      items
        ?.where((item) =>
          item
          .name
          .toLowerCase()
          .contains(query.toLowerCase())
        )
        ?.toList();

    yield _search((CacheManager.get("attachments") as List<dynamic>)?.whereType<ClasseVivaAttachment>()?.toList(), query);

    await checkValidSession();

		final result = await HttpManager.get(
      url: _endpoints.attachments(),
      headers: getSessionCookieHeader(),
    );

    if (result.isError) return;

		final document = parse(result.response.body);

		List<ClasseVivaAttachment> attachments = [];

		document.querySelectorAll(".contenuto").forEach((attachment) {
			final id = attachment.attributes["contenuto_id"];

			ClasseVivaAttachmentType type;
			String url;

      switch(attachment.querySelector("img").attributes["src"].split("/").last.split(".").first)
      {
        case "file": type = ClasseVivaAttachmentType.File; break;
        case "link": type = ClasseVivaAttachmentType.Link; break;
        case "testo": type = ClasseVivaAttachmentType.Text; break;
      }

			switch (type)
			{
				case ClasseVivaAttachmentType.File:
          url = _endpoints.fileAttachments(id, attachment.querySelector(".button_action").attributes["cksum"]);
          break;
				case ClasseVivaAttachmentType.Link:
          url = attachment.querySelector(".button_action").attributes["ref"];
          break;
				case ClasseVivaAttachmentType.Text:
          url = _endpoints.textAttachments(id);
          break;
			}

      final String dateString = attachment
        .querySelector(".contenuto_desc div span:last-child")
        .text
        .trim()
        .split(" ")
        [2];

      final String timeString = attachment
        .querySelector(".contenuto_desc div span:last-child")
        .text
        .trim()
        .split(" ")
        .last;

      final dom.Element parentFolderElement = document.querySelector("[folder_id=\"${attachment.attributes["master_id"].trim()}\"]");

      String teacher;

      dom.Element tempElement = parentFolderElement;

      do
      {
        tempElement = tempElement.previousElementSibling;
      }
      while (tempElement.attributes["style"] != "height: 40px;");

      teacher = tempElement.querySelector("[colspan=\"12\"]").text.trim();

      // Remove unnecessary information (this will leave the element with only the folder name)
      // Use '?.' to avoid calling remove on null (the element was removed in a previous iteration)
      parentFolderElement.querySelector("td:last-child").querySelector("span")?.remove();

			attachments.add(ClasseVivaAttachment(
				id: id,
				teacher: teacher,
				name: attachment.querySelector(".row_contenuto_desc").text.trim(),
				folder: parentFolderElement.text.trim(),
				type: type,
				date: DateFormat("dd-MM-yyyy HH:mm:ss").parse("$dateString $timeString"),
				url: url,
      ));
		});

    attachments.sort((a, b) {
      // Most recent first
      return b.date.compareTo(a.date);
    });

    await CacheManager.set("attachments", attachments);

		yield _search(attachments, query);
	}

	Stream<List<ClasseVivaDemerit>> getDemerits() async* {
    yield (CacheManager.get("demerits") as List<dynamic>)?.whereType<ClasseVivaDemerit>()?.toList();

    await checkValidSession();

		final result = await HttpManager.get(
			url: _endpoints.demerits(),
      headers: getSessionCookieHeader(),
    );

		if (result.isError) return;

    final document = parse(result.response.body);

		List<ClasseVivaDemerit> demerits = [];

		document.querySelectorAll("#sort_table tbody tr").forEach((demerit) {
      final String dateString = demerit.querySelector(":nth-child(3)").text.trim();

			demerits.add(ClasseVivaDemerit(
				teacher: demerit.querySelector(":first-child").text.trim(),
				date: DateFormat("dd-MM-yyyy").parse(dateString),
				content: demerit.querySelector(":nth-child(5)").text.trim(),
				type: demerit.querySelector(":last-child").text.trim(),
			));
		});

    demerits.sort((a, b) {
      // Most recent first
      return b.date.compareTo(a.date);
    });

    await CacheManager.set("demerits", demerits);

		yield demerits;
	}

  Stream<List<ClasseVivaAbsence>> getAbsences() async* {
    yield (CacheManager.get("absences") as List<dynamic>)?.whereType<ClasseVivaAbsence>()?.toList();

    await checkValidSession();

		final result = await HttpManager.get(
			url: _endpoints.absences(),
      headers: getSessionCookieHeader(),
    );

		if (result.isError) return;

    final document = parse(result.response.body);

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
        final int year = getYear() + (fromMonthIndex < 7 ? 1 : 0);

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
            23, 59, 59,
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

        final int year = getYear() + (monthIndex < 7 ? 1 : 0);

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

        final int year = getYear() + (monthIndex < 7 ? 1 : 0);

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

    absences.sort((a, b) {
      // Most recent first
      return b.from.compareTo(a.from);
    });

    await CacheManager.set("absences", absences);

		yield absences;
	}

  Stream<List<ClasseVivaAbsenceMonth>> getAbsencesStats() async* {
    yield (CacheManager.get("absences-stats") as List<dynamic>)?.whereType<ClasseVivaAbsenceMonth>()?.toList();

    await checkValidSession();

		final result = await HttpManager.get(
			url: _endpoints.absences(),
      headers: getSessionCookieHeader(),
    );

		if (result.isError) return;

    final document = parse(result.response.body);

    final List<String> monthNames = [];

    document.querySelectorAll("#skeda_sintesi_xmese tr[height=\"38\"]").last.querySelectorAll("td[colspan=\"2\"]").getRange(0, 10).forEach((month) {
      monthNames.add(month.text.trim());
		});

    final List<ClasseVivaAbsenceMonth> months = [];

    int i = 0;

		document.querySelector("#skeda_sintesi_xmese tr[height=\"57\"]").querySelectorAll("td[colspan=\"2\"]").getRange(0, 10).forEach((month) {
      months.add(ClasseVivaAbsenceMonth(
        name: monthNames[i++],
        presencesCount: int.parse(month.querySelectorAll("p").first.text.trim()),
        absencesCount: int.parse(month.querySelectorAll("p")[1].text.trim()),
        delaysCount: int.parse(month.querySelectorAll("p")[2].text.trim()),
        exitsCount: int.parse(month.querySelectorAll("p").last.text.trim()),
      ));
		});

    await CacheManager.set("absences-stats", months);

		yield months;
	}

  Stream<List<ClasseVivaSubject>> getSubjects() async* {
    yield (CacheManager.get("subjects") as List<dynamic>)?.whereType<ClasseVivaSubject>()?.toList();

    await checkValidSession();

		final result = await HttpManager.get(
			url: _endpoints.subjects(),
      headers: getSessionCookieHeader(),
    );

		if (result.isError) return;

    final document = parse(result.response.body);

		List<ClasseVivaSubject> subjects = [];

		document.querySelectorAll("#data_table .materia").forEach((subject) {
			subjects.add(ClasseVivaSubject(
				id: subject.attributes["materia_id"],
        name: subject.attributes["title"],
        teacherIds: subject.attributes["autori_id"].split(","),
			));
		});

    await CacheManager.set("subjects", subjects);

		yield subjects;
	}

  Stream<List<ClasseVivaLesson>> getLessons(ClasseVivaSubject subject) async* {
    yield (CacheManager.get("lessons-${subject.id}") as List<dynamic>)?.whereType<ClasseVivaLesson>()?.toList();

    await checkValidSession();

		final result = await HttpManager.get(
			url: _endpoints.lessons(subject.id, subject.teacherIds),
      headers: getSessionCookieHeader(),
    );

    if (result.isError) return;

		final document = parse('''
      <!DOCTYPE html>
      <html>
        <head>
        </head>
        <body>
          <table>
            <tbody>
            ${result.response.body}
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
        date: DateFormat("dd-MM-yyyy").parse(dateString),
        description: lesson.querySelector("td:nth-child(5)").text.trim(),
      ));
		});

    await CacheManager.set("lessons-${subject.id}", lessons);

		yield lessons;
	}

  Stream<List<ClasseVivaBulletinBoardItem>> getBulletinBoard({ String query = "", bool hideInactive = true }) async* {
    List<ClasseVivaBulletinBoardItem> _search(List<ClasseVivaBulletinBoardItem> items, String query) =>
      items
        ?.where((item) =>
          item
          .titolo
          .toLowerCase()
          .contains(query.toLowerCase())
        )
        ?.toList();

    yield _search((CacheManager.get("bulletin-board-$hideInactive") as List<dynamic>)?.whereType<ClasseVivaBulletinBoardItem>()?.toList(), query);

    await checkValidSession();

		final result = await HttpManager.get(
			url: _endpoints.bulletinBoard(hideInactive),
      headers: getSessionCookieHeader(),
    );

    if (result.isError) return;

    final jsonResponse = jsonDecode("${result.response.body}");

    List responseItems = [];

    if (jsonResponse != null && !(jsonResponse is List))
    {
      if (jsonResponse["msg_new"] != null) responseItems.addAll(jsonResponse["msg_new"]);

      if (jsonResponse["read"] != null) responseItems.addAll(jsonResponse["read"]);
    }

    List<ClasseVivaBulletinBoardItem> items = responseItems.map((item) => ClasseVivaBulletinBoardItem.fromJson(item)).toList();

    items.sort((a, b) {
      // Most recent first
      return b.eventDate.compareTo(a.eventDate);
    });

    await CacheManager.set("bulletin-board-$hideInactive", items);

		yield _search(items, query);
	}

  Stream<ClasseVivaBulletinBoardItemDetails> getBulletinBoardItemDetails(String id) async* {
    yield CacheManager.get("bulletin-board-item-$id");

    await checkValidSession();

		final result = await HttpManager.get(
			url: _endpoints.bulletinBoardItemDetails(id),
      headers: getSessionCookieHeader(),
    );

    if (result.isError) return;

    final document = parse('''
      <!DOCTYPE html>
      <html>
        <head>
        </head>
        <body>
          ${result.response.body}
        </body>
      </html>
    ''');

    final ClasseVivaBulletinBoardItemDetails itemDetails = ClasseVivaBulletinBoardItemDetails(
      id: document.querySelector("[comunicazione_id]").attributes["comunicazione_id"],
      title: document.querySelector("div:first-child").text.trim(),
      description: document.querySelector(".comunicazione_testo").text.trim(),
      attachments: document.querySelectorAll("[allegato_id]").map((attachment) => ClasseVivaBulletinBoardItemDetailsAttachment(
        id: attachment.attributes["allegato_id"],
        name: attachment.text.trim(),
      )).toList(),
    );

    await CacheManager.set("bulletin-board-item-$id", itemDetails);

    yield itemDetails;
	}

  Stream<ClasseVivaCalendar> getCalendar(DateTime date) async* {
    yield CacheManager.get("calendar-${date.year}-${date.month}-${date.day}");

    await checkValidSession();

		final result = await HttpManager.get(
			url: _endpoints.calendar(date),
      headers: getSessionCookieHeader(),
    );

    if (result.isError) return;

    final document = parse(result.response.body);

    List<ClasseVivaCalendarLesson> lessons = [];

    document.querySelectorAll("#data_table").last.querySelectorAll(".rigtab").forEach((lesson) {
      if (lesson.querySelector(".registro_firma_dett_docente") == null
        || lesson.id != "") return;

      String subject = lesson.querySelector(".registro_firma_dett_materia").attributes["title"];

      if (subject == ":materia_estesa:")
      {
        subject = lesson.querySelector(".registro_firma_dett_materia span:first-child").text.trim();
      }

      lessons.add(ClasseVivaCalendarLesson(
        teacher: lesson.querySelector(".registro_firma_dett_docente div:first-child").text.trim(),
        subject: subject,
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

    await for (final ClasseVivaCalendar calendar in CombineLatestStream.combine3<List<ClasseVivaGrade>, List<ClasseVivaAgendaItem>, List<ClasseVivaAbsence>, ClasseVivaCalendar>(
      getGrades(),
      getAgenda(date, DateTime(
        date.year,
        date.month,
        date.day,
        23, 59, 59,
      )),
      getAbsences(),
      (grades, agenda, absences) {
        if (grades == null || agenda == null || absences == null) return null;

        agenda.sort((a, b) {
          // Earliest first
          return a.start.compareTo(b.start);
        });

        final ClasseVivaCalendar calendar = ClasseVivaCalendar(
          date: date,
          grades: grades.where((grade) => grade.date.isAtSameMomentAs(date)).toList(),
          lessons: lessons,
          agenda: agenda,
          absences:
            absences
              .where((absence)
              {
                if (absence.type == ClasseVivaAbsenceType.Absence)
                  return (date.isAfter(absence.from) || date == absence.from) && date.isBefore(absence.to);
                else
                  return absence.from == date;
              })
              .toList(),
        );

        return calendar;
      },
    ))
    {
      if (calendar == null) continue;

      await CacheManager.set("calendar-${date.year}-${date.month}-${date.day}", calendar);

      yield calendar;
    }
	}

  Stream<List<ClasseVivaFinalGrade>> getFinalGrades() async* {
    yield (CacheManager.get("final-grades") as List<dynamic>)?.whereType<ClasseVivaFinalGrade>()?.toList();

    await checkValidSession();

		final result = await HttpManager.get(
			url: _endpoints.finalGrades(),
      headers: getSessionCookieHeader(),
    );

    if (result.isError) return;

    final document = parse(result.response.body);

    List<ClasseVivaFinalGrade> finalGrades = [];

    document.querySelector("#table_documenti").querySelectorAll(".rigtab").forEach((element) {
      finalGrades.add(ClasseVivaFinalGrade(
        type: element.querySelector(".align_middle").text.trim(),
        url: _endpoints.baseUrl + element.querySelectorAll("td").last.querySelector("span").attributes["xhref"],
      ));
    });

    await CacheManager.set("final-grades", finalGrades);

    yield finalGrades;
	}

  Stream<List<ClasseVivaBook>> getBooks() async* {
    yield (CacheManager.get("books") as List<dynamic>)?.whereType<ClasseVivaBook>()?.toList();

    await checkValidSession();

		final result = await HttpManager.get(
			url: _endpoints.books(),
      headers: getSessionCookieHeader(),
    );

    if (result.isError) return;

    final document = parse(result.response.body);

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

    await CacheManager.set("books", books);

    yield books;
	}

  Stream<List<ClasseVivaMessage>> getMessages() async* {
    yield (CacheManager.get("messages") as List<dynamic>)?.whereType<ClasseVivaMessage>()?.toList();

    await checkValidSession();

		final result = await HttpManager.get(
			url: _endpoints.messages(messagesPerPage: 50),
      headers: getSessionCookieHeader(),
    );

    if (result.isError) return;

    final List<ClasseVivaMessage> messages = (jsonDecode(result.response.body)["OAS"]["rows"] as List).map((item) => ClasseVivaMessage.fromJson(item)).toList();

    messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    await CacheManager.set("messages", messages);

    yield messages;
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
    final List<ClasseVivaSession> sessions = ClasseViva.getAllSessions();

    sessions.add(session);

    await PreferencesManager.set("sessions", sessions.map((session) => session.toString()).toList());
  }

  static ClasseVivaSession getCurrentSession() {
    final String session = PreferencesManager.get("currentSession");

    if (session == null) return null;

    return ClasseVivaSession.fromString(session);
  }

  static Future<void> setCurrentSession(ClasseVivaSession session) async {
    await PreferencesManager.set("currentSession", session.toString());
  }

  static List<ClasseVivaSession> getAllSessions() {
    final List<String> sessions = PreferencesManager.get("sessions");

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