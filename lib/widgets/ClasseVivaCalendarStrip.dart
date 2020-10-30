import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClasseVivaCalendarStrip extends StatefulWidget {
  final DateTime selectedDate;

  final void Function(DateTime) onDateChange;

  final ClasseVivaCalendarStripController controller;

  ClasseVivaCalendarStrip({
    @required this.selectedDate,
    @required this.onDateChange,
    @required this.controller,
  });

  @override
  _ClasseVivaCalendarStripState createState() => _ClasseVivaCalendarStripState();
}

class _ClasseVivaCalendarStripState extends State<ClasseVivaCalendarStrip> {
  final ClasseViva _session = ClasseViva.current;

  bool _isSelected(DateTime date) => date == widget.selectedDate;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
      .addPostFrameCallback((_) => widget.controller.jumpTo(widget.selectedDate));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: ListView.builder(
        controller: widget.controller._scrollController,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: _session.yearEndsAt.difference(_session.yearBeginsAt).inDays + 1,
        itemBuilder: (context, index) {
          final DateTime date = DateTime(
            _session.yearBeginsAt.year,
            _session.yearBeginsAt.month,
            index + 1,
          );

          return Container(
            height: 80,
            width: MediaQuery.of(context).size.width / 7, // 7 days in a row
            color: _isSelected(date) ? Colors.blueAccent.shade400 : Colors.transparent,
            child: InkWell(
              onTap: () => widget.onDateChange(date),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat(DateFormat.ABBR_WEEKDAY).format(date),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _isSelected(date) ? Colors.white : Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _isSelected(date) ? Colors.white : Colors.white70,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    DateFormat(DateFormat.ABBR_MONTH).format(date),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _isSelected(date) ? Colors.white : Colors.white70,
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

class ClasseVivaCalendarStripController
{
  final BuildContext context;

  final ScrollController _scrollController = ScrollController();

  ClasseVivaCalendarStripController({ @required this.context });

  static ClasseVivaCalendarStripController of(BuildContext context) => ClasseVivaCalendarStripController(context: context);

  double _getDateScrollOffset(DateTime date) => date.difference(ClasseViva.current.yearBeginsAt).inDays * MediaQuery.of(context).size.width / 7;

  void jumpTo(DateTime date) => _scrollController.jumpTo(_getDateScrollOffset(date));

  void animateTo(DateTime date) => _scrollController.animateTo(
    _getDateScrollOffset(date),
    duration: Duration(milliseconds: 100),
    curve: Curves.linear,
  );
}