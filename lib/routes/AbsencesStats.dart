import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaAbsenceMonth.dart';
import 'package:classeviva_lite/widgets/ClasseVivaRefreshableView.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class AbsencesStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClasseVivaRefreshableView<List<ClasseVivaAbsenceMonth>>(
      title: "Infografica",
      stream: () => ClasseViva.current.getAbsencesStats(),
      builder: (months) {
        return charts.BarChart(
          months.map((month) => charts.Series(
            id: month.name,
            data: [
              _EventsPerMonth(month: month.name, count: month.presencesCount, color: Colors.green),
              _EventsPerMonth(month: month.name, count: month.absencesCount, color: Colors.red),
              _EventsPerMonth(month: month.name, count: month.delaysCount, color: Colors.orange),
              _EventsPerMonth(month: month.name, count: month.exitsCount, color: Colors.yellow),
            ],
            domainFn: (_EventsPerMonth e, _) => e.month,
            measureFn: (_EventsPerMonth e, _) => e.count,
            colorFn: (_EventsPerMonth e, _) => e.color,
          )).toList(),
          animate: true,
          barGroupingType: charts.BarGroupingType.stacked,
        );
      },
      isResultEmpty: (result) => false,
      emptyResultMessage: null,
    );
  }
}

class _EventsPerMonth
{
  final String month;

  final int count;

  final charts.Color color;

  _EventsPerMonth({
    @required this.month,
    @required this.count,
    @required Color color,
  }):
    this.color = charts.Color(
      a: color.alpha,
      r: color.red,
      g: color.green,
      b: color.blue,
    );
}