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
                          month.presencesCount,
                          month.absencesCount,
                          month.delaysCount,
                          month.exitsCount,
                        ],
                        domainFn: (int n, _) => month.name,
                        measureFn: (int n, _) => n,
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