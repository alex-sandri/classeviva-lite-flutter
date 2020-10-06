import 'package:calendar_views/calendar_views.dart';
import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaAbsence.dart';
import 'package:classeviva_lite/models/ClasseVivaCalendar.dart';
import 'package:classeviva_lite/models/ClasseVivaCalendarLesson.dart';
import 'package:classeviva_lite/routes/Absences.dart';
import 'package:classeviva_lite/routes/Agenda.dart';
import 'package:classeviva_lite/routes/grades.dart';
import 'package:classeviva_lite/miscellaneous/theme_manager.dart';
import 'package:classeviva_lite/widgets/ClasseVivaCalendarStrip.dart';
import 'package:classeviva_lite/widgets/ClasseVivaRefreshableWidget.dart';
import 'package:flutter/material.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final ClasseViva _session = ClasseViva.current;

  DateTime _date = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  ClasseVivaCalendarStripController _calendarStripController;

  DaysPageController _daysPageController;

  void _setDate(DateTime date) {
    _calendarStripController.animateTo(date);

    _daysPageController.jumpToDay(date);

    setState(() => _date = DateTime(date.year, date.month, date.day));
  }

  void initState() {
    super.initState();

    _calendarStripController = ClasseVivaCalendarStripController.of(context);

    if (_session.yearEndsAt.isBefore(_date))
      _date = _session.yearEndsAt;
  }

  @override
  Widget build(BuildContext context) {
    _daysPageController = DaysPageController(
      daysPerPage: 1,
      firstDayOnInitialPage: _date,
    );

    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Registro"),
          actions: [
            IconButton(
              icon: Icon(Icons.today),
              tooltip: "Oggi",
              onPressed: () => _setDate(DateTime.now()),
            ),
            IconButton(
              icon: Icon(Icons.calendar_today),
              tooltip: "Cambia giorno",
              onPressed: () async {
                final DateTime selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: _session.yearBeginsAt,
                  lastDate: _session.yearEndsAt,
                );

                if (selectedDate != null) _setDate(selectedDate);
              },
            ),
          ],
          bottom: PreferredSize(
            // Height of the ClasseVivaCalendarStrip widget
            preferredSize: Size.fromHeight(80),
            child: ClasseVivaCalendarStrip(
              selectedDate: _date,
              onDateChange: _setDate,
              controller: _calendarStripController,
            ),
          ),
        ),
        body: DaysPageView(
          controller: _daysPageController,
          onDaysChanged: (dates) => _setDate(dates.first),
          pageBuilder: (context, dates) {
            return ClasseVivaRefreshableWidget<ClasseVivaCalendar>(
              stream: () => ClasseViva.current.getCalendar(dates.first),
              builder: (calendar) {
                return ListView(
                  children: [
                    if (calendar == null)
                      LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(ThemeManager.isLightTheme(context)
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).accentColor),
                      ),

                    if (calendar != null && calendar.absences.isNotEmpty)
                      ListTile(
                        title: Text("Assenze"),
                      ),

                    if (calendar != null && calendar.absences.isNotEmpty)
                      ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        separatorBuilder: (context, index) => Divider(),
                        itemCount: calendar.absences.length,
                        itemBuilder: (context, index) {
                          final ClasseVivaAbsence absence = calendar.absences[index];

                          Color color;

                          switch (absence.type)
                          {
                            case ClasseVivaAbsenceType.Absence:
                              color = Colors.red;
                              break;
                            case ClasseVivaAbsenceType.Late:
                            case ClasseVivaAbsenceType.ShortDelay:
                              color = Colors.orange;
                              break;
                            case ClasseVivaAbsenceType.EarlyExit:
                              color = Colors.yellow;
                              break;
                          }

                          return Card(
                            color: color,
                            child: ListTile(
                              leading: Icon(Icons.error),
                              title: SelectableText(Absences.getTypeString(absence.type)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SelectableText(Absences.getStatusString(absence.status)),

                                  if (absence.description.isNotEmpty)
                                    SelectableText(
                                      absence.description,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    if (calendar != null && calendar.grades.isNotEmpty)
                      ListTile(
                        title: Text(
                          "Voti",
                        ),
                      ),

                    if (calendar != null && calendar.grades.isNotEmpty)
                      ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        separatorBuilder: (context, index) => Divider(),
                        itemCount: calendar.grades.length,
                        itemBuilder: (context, index) => GradeTile(calendar.grades[index], showDay: false),
                      ),

                    if (calendar != null)
                      ListTile(
                        title: Text(
                          "Lezioni",
                        ),
                      ),
                        
                    if (calendar != null)
                      ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        separatorBuilder: (context, index) => Divider(),
                        itemCount: calendar.lessons.isNotEmpty
                          ? calendar.lessons.length
                          : 1,
                        itemBuilder: (context, index) {
                          if (calendar.lessons.isEmpty)
                            return SelectableText(
                              "Nessun evento",
                              textAlign: TextAlign.center,
                            );

                          final ClasseVivaCalendarLesson lesson = calendar.lessons[index];

                          return ListTile(
                            leading: Column(
                              children: [
                                SelectableText(
                                  "${lesson.hour}ª ora",
                                ),
                                SelectableText(
                                  "${lesson.duration.inHours} ${lesson.duration.inHours == 1 ? "ora" : "ore"}",
                                  style: TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            title: SelectableText(
                              lesson.subject,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SelectableText(
                                  lesson.teacher,
                                ),
                                SelectableText.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: lesson.type,
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                      TextSpan(text: " "),
                                      TextSpan(text: lesson.description),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                    if (calendar != null && calendar.agenda.isNotEmpty)
                      ListTile(
                        title: Text(
                          "Agenda",
                        ),
                      ),

                    if (calendar != null && calendar.agenda.isNotEmpty)
                      ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        separatorBuilder: (context, index) => Divider(),
                        itemCount: calendar.agenda.length,
                        itemBuilder: (context, index) => AgendaItemTile(calendar.agenda[index]),
                      ),
                  ],
                );
              },
              isResultEmpty: (result) => false,
              emptyResultMessage: null,
            );
          }
        ),
      ),
    );
  }
}