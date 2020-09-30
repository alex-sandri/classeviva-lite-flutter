import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClasseVivaCalendarStrip extends StatefulWidget {
  final void Function(DateTime) onDateChanged;

  ClasseVivaCalendarStrip({
    @required this.onDateChanged,
  });

  @override
  _ClasseVivaCalendarStripState createState() => _ClasseVivaCalendarStripState();
}

class _ClasseVivaCalendarStripState extends State<ClasseVivaCalendarStrip> {
  final ClasseViva _session = ClasseViva.current;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _session.yearEndsAt.difference(_session.yearBeginsAt).inDays + 1,
      itemBuilder: (context, index) {
        final DateTime date = _session.yearBeginsAt.add(Duration(days: index));

        return ListTile(
          title: Text(date.day.toString()),
          subtitle: Text(DateFormat.M().format(date)),
          onTap: () {
            // TODO
            print(date);

            widget.onDateChanged(date);
          },
        );
      },
    );
  }
}