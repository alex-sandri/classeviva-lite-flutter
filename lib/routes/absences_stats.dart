import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class AbsencesStats extends StatefulWidget {
  @override
  _AbsencesStatsState createState() => _AbsencesStatsState();
}

class _AbsencesStatsState extends State<AbsencesStats> {
  final ClasseViva _session = ClasseViva(ClasseViva.getCurrentSession());

  List<ClasseVivaAbsenceMonth> _months;

  Future<void> _handleRefresh() async {
    await for (final List<ClasseVivaAbsenceMonth> months in _session.getAbsencesStats().asStream())
    {
      if (months == null) continue;

      if (mounted)
        setState(() {
          _months = months;
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
          title: Text("Infografica"),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  backgroundColor: Theme.of(context).appBarTheme.color,
                  child: _months == null
                  ? Spinner()
                  : charts.BarChart(
                      _months.map((month) => charts.Series(
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
                    ),
                ),
              ),
            ],
          ),
        ),
      ),
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