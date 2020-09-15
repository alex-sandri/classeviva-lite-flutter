import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaAbsence.dart';
import 'package:classeviva_lite/models/ClasseVivaCalendar.dart';
import 'package:classeviva_lite/models/ClasseVivaCalendarLesson.dart';
import 'package:classeviva_lite/routes/absences.dart';
import 'package:classeviva_lite/routes/agenda.dart';
import 'package:classeviva_lite/routes/grades.dart';
import 'package:classeviva_lite/miscellaneous/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final ClasseViva _session = ClasseViva(ClasseViva.getCurrentSession());

  ClasseVivaCalendar _calendar;

  DateTime _date = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  Future<void> _handleRefresh() async {
    await for (final ClasseVivaCalendar calendar in _session.getCalendar(_date))
    {
      if (calendar == null) continue;

      if (mounted && _date.isAtSameMomentAs(calendar.date))
        setState(() {
          _calendar = calendar;
        });
    }
  }

  void initState() {
    super.initState();

    _handleRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Registro'
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.calendar_today),
              tooltip: "Cambia giorno",
              onPressed: () async {
                final DateTime selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(1970),
                  lastDate: DateTime(2099),
                );

                if (selectedDate != null)
                {
                  setState(() {
                    _date = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

                    _calendar = null;
                  });

                  _handleRefresh();
                }
              },
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  backgroundColor: Theme.of(context).appBarTheme.color,
                  child: ListView(
                    children: [
                      ListTile(
                        leading: IconButton(
                          icon: Icon(
                            Icons.chevron_left,
                          ),
                          tooltip: "Giorno precedente",
                          onPressed: () {
                            setState(() {
                              _date = _date.subtract(Duration(days: 1));

                              _calendar = null;
                            });

                            _handleRefresh();
                          },
                        ),
                        title: Center(
                          child: Text(
                            DateFormat.yMMMMEEEEd().format(_date),
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.chevron_right,
                          ),
                          tooltip: "Giorno successivo",
                          onPressed: () {
                            setState(() {
                              _date = _date.add(Duration(days: 1));

                              _calendar = null;
                            });

                            _handleRefresh();
                          },
                        ),
                      ),

                      if (_calendar == null)
                        LinearProgressIndicator(
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(ThemeManager.isLightTheme(context)
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).accentColor),
                        ),

                      if (_calendar != null && _calendar.absences.isNotEmpty)
                        ListTile(
                          title: Text("Assenze"),
                        ),

                      if (_calendar != null && _calendar.absences.isNotEmpty)
                        ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          separatorBuilder: (context, index) => Divider(),
                          itemCount: _calendar.absences.length,
                          itemBuilder: (context, index) {
                            final ClasseVivaAbsence absence = _calendar.absences[index];

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

                      if (_calendar != null && _calendar.grades.isNotEmpty)
                        ListTile(
                          title: Text(
                            "Voti",
                          ),
                        ),

                      if (_calendar != null && _calendar.grades.isNotEmpty)
                        ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          separatorBuilder: (context, index) => Divider(),
                          itemCount: _calendar.grades.length,
                          itemBuilder: (context, index) => GradeTile(_calendar.grades[index], showDay: false),
                        ),

                      if (_calendar != null)
                        ListTile(
                          title: Text(
                            "Lezioni",
                          ),
                        ),
                      
                      if (_calendar != null)
                        ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          separatorBuilder: (context, index) => Divider(),
                          itemCount: _calendar.lessons.isNotEmpty
                            ? _calendar.lessons.length
                            : 1,
                          itemBuilder: (context, index) {
                            if (_calendar.lessons.isEmpty)
                              return SelectableText(
                                "Nessun evento",
                                textAlign: TextAlign.center,
                              );

                            final ClasseVivaCalendarLesson lesson = _calendar.lessons[index];

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

                      if (_calendar != null && _calendar.agenda.isNotEmpty)
                        ListTile(
                          title: Text(
                            "Agenda",
                          ),
                        ),

                      if (_calendar != null && _calendar.agenda.isNotEmpty)
                        ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          separatorBuilder: (context, index) => Divider(),
                          itemCount: _calendar.agenda.length,
                          itemBuilder: (context, index) => AgendaItemTile(_calendar.agenda[index], showDay: false),
                        ),
                    ],
                  ),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}