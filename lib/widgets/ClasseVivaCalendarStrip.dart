import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClasseVivaCalendarStrip extends StatefulWidget {
  final void Function(DateTime) onDateChange;

  ClasseVivaCalendarStrip({
    @required this.onDateChange,
  });

  @override
  _ClasseVivaCalendarStripState createState() => _ClasseVivaCalendarStripState();
}

class _ClasseVivaCalendarStripState extends State<ClasseVivaCalendarStrip> {
  final ClasseViva _session = ClasseViva.current;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: _session.yearEndsAt.difference(_session.yearBeginsAt).inDays + 1,
        itemBuilder: (context, index) {
          final DateTime date = _session.yearBeginsAt.add(Duration(days: index));

          return Container(
            height: 80,
            width: MediaQuery.of(context).size.width / 7, // 7 days in a row
            child: ListTile(
              title: Text(date.day.toString()),
              subtitle: Text(DateFormat.M().format(date)),
              onTap: () {
                // TODO

                widget.onDateChange(date);
              },
            ),
          );
        },
      ),
    );
  }
}