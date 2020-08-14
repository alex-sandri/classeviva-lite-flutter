import 'package:classeviva_lite/classeviva.dart';
import 'package:classeviva_lite/routes/agenda.dart';
import 'package:classeviva_lite/routes/grades.dart';
import 'package:classeviva_lite/theme_manager.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  ClasseViva _session;

  ClasseVivaCalendar _calendar;

  DateTime _date = DateTime.now();

  Future<void> _handleRefresh() async {
    setState(() {
      _calendar = null;
    });

    final ClasseVivaCalendar calendar = await _session.getCalendar(_date);

    if (mounted)
      setState(() {
        _calendar = calendar;
      });
  }

  void initState() {
    super.initState();

    ClasseViva.getCurrentSession().then((session) {
      _session = ClasseViva(
        session: session,
        context: context
      );

      _handleRefresh();
    });
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
              onPressed: () async {
                final DateTime selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(1970),
                  lastDate: DateTime(2099),
                );

                if (selectedDate != null)
                {
                  _date = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

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
          child: _session == null
            ? Spinner()
            : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: _calendar == null
                  ? Spinner()
                  : ListView(
                      children: [
                        if (_calendar.grades.isNotEmpty)
                          ListTile(
                            title: Text(
                              "Voti",
                            ),
                          ),
                        
                        if (_calendar.grades.isNotEmpty)
                          ListView.separated(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            separatorBuilder: (context, index) => Divider(),
                            itemCount: _calendar.grades.length,
                            itemBuilder: (context, index) => GradeTile(_calendar.grades[index], showDay: false),
                          ),

                        ListTile(
                          title: Text(
                            "Lezioni",
                          ),
                        ),
                        ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          separatorBuilder: (context, index) => Divider(),
                          itemCount: _calendar.lessons.length + 1,
                          itemBuilder: (context, index) {
                            if (_calendar.lessons.isEmpty)
                              return SelectableText(
                                "Nessun evento",
                                textAlign: TextAlign.center,
                              );

                            if (index == _calendar.lessons.length) return Container();

                            final ClasseVivaCalendarLesson lesson = _calendar.lessons[index];

                            return ListTile(
                              leading: Column(
                                children: [
                                  SelectableText(
                                    "${lesson.hour}^ ora",
                                  ),
                                  SelectableText(
                                    "${lesson.duration.inHours}hh",
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
                                  SelectableText(
                                    lesson.type,
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                  SelectableText(
                                    lesson.description,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        if (_calendar.agenda.isNotEmpty)
                          ListTile(
                            title: Text(
                              "Agenda",
                            ),
                          ),

                        if (_calendar.agenda.isNotEmpty)
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