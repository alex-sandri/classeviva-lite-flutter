import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClasseVivaCalendarStrip extends StatefulWidget {
  final DateTime selectedDate;

  final void Function(DateTime) onDateChange;

  ClasseVivaCalendarStrip({
    @required this.selectedDate,
    @required this.onDateChange,
  });

  @override
  _ClasseVivaCalendarStripState createState() => _ClasseVivaCalendarStripState();
}

class _ClasseVivaCalendarStripState extends State<ClasseVivaCalendarStrip> {
  final ClasseViva _session = ClasseViva.current;

  final ScrollController _scrollController = ScrollController();

  bool _isSelected(DateTime date) => date == widget.selectedDate;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
      .addPostFrameCallback((_) => _scrollController.jumpTo(widget.selectedDate.difference(_session.yearBeginsAt).inDays * MediaQuery.of(context).size.width / 7));
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance
      .addPostFrameCallback((_) => _scrollController.animateTo(
        widget.selectedDate.difference(_session.yearBeginsAt).inDays * MediaQuery.of(context).size.width / 7,
        duration: Duration(milliseconds: 100),
        curve: Curves.linear,
      ));

    return Container(
      height: 80,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: _session.yearEndsAt.difference(_session.yearBeginsAt).inDays + 1,
        itemBuilder: (context, index) {
          final DateTime date = _session.yearBeginsAt.add(Duration(days: index));

          return Container(
            height: 80,
            width: MediaQuery.of(context).size.width / 7, // 7 days in a row
            color: _isSelected(date) ? Colors.blueAccent.shade400 : Colors.transparent,
            child: GestureDetector(
              onTap: () => widget.onDateChange(date),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat(DateFormat.ABBR_WEEKDAY).format(date),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    DateFormat(DateFormat.ABBR_MONTH).format(date),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}