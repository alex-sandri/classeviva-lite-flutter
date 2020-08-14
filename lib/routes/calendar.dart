import 'package:classeviva_lite/classeviva.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  ClasseViva _session;

  ClasseVivaCalendar _calendar;

  DateTime _date = DateTime.now();

  Future<void> _handleRefresh() async {
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
                  color: Theme.of(context).primaryColor,
                  child: _calendar == null
                  ? Spinner()
                  : ListView.separated(
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: _calendar.lessons.length,
                      itemBuilder: (context, index) {
                        final ClasseVivaCalendarLesson lesson = _calendar.lessons[index];

                        return ListTile(
                          leading: Column(
                            children: [
                              SelectableText(
                                "${lesson.hour}^ ora",
                              ),
                              SelectableText(
                                "${lesson.duration.inHours}hh",
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
                                lesson.description,
                              ),
                            ],
                          ),
                        );
                      },
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