import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/miscellaneous/theme_manager.dart';
import 'package:classeviva_lite/models/ClasseVivaGrade.dart';
import 'package:classeviva_lite/models/ClasseVivaGradesPeriod.dart';
import 'package:classeviva_lite/widgets/ClasseVivaRefreshableWidget.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Grades extends StatefulWidget {
  @override
  _GradesState createState() => _GradesState();
}

class _GradesState extends State<Grades> {
  final ClasseViva _session = ClasseViva.current;

  List<ClasseVivaGradesPeriod> _periods = [];

  Future<void> _fetchPeriods() async {
    await for (final List<ClasseVivaGradesPeriod> periods in _session.getPeriods())
    {
      if (periods == null) continue;

      if (mounted)
        setState(() {
          _periods = periods;
        });
    }
  }

  void initState() {
    super.initState();

    _fetchPeriods();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: DefaultTabController(
        length: 2 + _periods.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Valutazioni"),
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                Tab(
                  icon: Icon(Icons.grade),
                  text: "Ultime Valutazioni",
                ),
                Tab(
                  icon: Icon(Icons.assessment),
                  text: "Riepilogo",
                ),
                ..._periods.map((period) {
                  return Tab(
                    icon: Icon(Icons.calendar_today),
                    text: period.name,
                  );
                }),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ClasseVivaRefreshableWidget<List<ClasseVivaGrade>>(
                stream: () => ClasseViva.current.getGrades(),
                builder: (grades) {
                  return ListView.builder(
                    itemCount: grades.length,
                    itemBuilder: (context, index) => GradeTile(grades[index]),
                  );
                },
                isResultEmpty: (result) => result.isEmpty,
                emptyResultMessage: "Non sono presenti valutazioni",
              ),
              ClasseVivaRefreshableWidget<List<ClasseVivaGrade>>(
                stream: () => ClasseViva.current.getGrades(),
                builder: (grades) => _GradesAveragesList(title: "Totale", grades: grades),
                isResultEmpty: (result) => result.isEmpty,
                emptyResultMessage: "Non sono presenti valutazioni",
              ),
              ..._periods.map((period) {
                return ClasseVivaRefreshableWidget<List<ClasseVivaGrade>>(
                  stream: () => ClasseViva.current.getGrades(),
                  builder: (grades) => _GradesAveragesList(title: period.name, grades: period.grades),
                  isResultEmpty: (result) => result.isEmpty,
                  emptyResultMessage: "Non sono presenti valutazioni",
                );
              }),
            ]
          ),
        ),
      ),
    );
  }
}

class GradeTile extends StatelessWidget {
  final ClasseVivaGrade grade;

  final bool showDay;

  GradeTile(this.grade, { this.showDay = true, });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: true,
      leading: CircleAvatar(
        child: Text(
          grade.grade,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        backgroundColor: ClasseViva.getGradeColor(grade),
        foregroundColor: Colors.white,
        radius: 25,
      ),
      title: SelectableText(
        grade.subject,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              if (showDay)
                SelectableText(
                  DateFormat.yMMMMd().format(grade.date),
                ),

              Expanded(
                child: SelectableText(
                  showDay ? " - ${grade.type}" : grade.type,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          SelectableLinkify(
            text: grade.description,
            options: LinkifyOptions(humanize: false),
            onOpen: (link) async {
              if (await canLaunch(link.url)) await launch(link.url);
              else
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Errore"),
                      content: Text("Impossibile aprire il link"),
                    );
                  },
                );
            },
          ),
        ],
      )
    );
  }
}

class _GradesAveragesList extends StatelessWidget {
  final String title;

  final List<ClasseVivaGrade> grades;

  _GradesAveragesList({
    @required this.title,
    @required this.grades
  });

  Text _getAverageGradeChangeTextWidget(double previous, double current) {
    bool changed = previous != current;
    bool increased = current > previous;

    return Text(
      changed
        ? (increased
            ? "↑"
            : "↓"
          )
        : "=",
      style: TextStyle(
        color: changed
          ? (increased
              ? Colors.green
              : Colors.red
            )
          : Colors.orange,
        fontSize: 30,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<ClasseVivaGrade>> subjects = groupBy(grades, (grade) => grade.subject);

    return ListView.builder(
      itemCount: subjects.length + 1,
      itemBuilder: (context, index) {
        if (index == 0)
          return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Media $title",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 8,),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(
                          value: ClasseViva.getAverageGrade(subjects.values.expand((element) => element).toList()) / 10,
                          valueColor: AlwaysStoppedAnimation<Color>(ClasseViva.getGradeColor(ClasseVivaGrade(
                            subject: "",
                            grade: ClasseViva.getAverageGrade(subjects.values.expand((element) => element).toList()).toStringAsFixed(1),
                            type: "",
                            description: "",
                            date: DateTime.now(),
                          ))),
                        ),
                      ),
                      Text(
                        ClasseViva.getAverageGrade(subjects.values.expand((element) => element).toList()).toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );

        final String subject = subjects.keys.elementAt(index - 1);
        final List<ClasseVivaGrade> grades = subjects.values.elementAt(index - 1);

        final List<ClasseVivaGrade> gradesValidForAverageCount = ClasseViva.getGradesValidForAverageCount(grades);

        final ClasseVivaGrade lastGrade = gradesValidForAverageCount.first;

        final double previousAverageGrade = ClasseViva.getAverageGrade(gradesValidForAverageCount.where((grade) => grade != lastGrade).toList());
        final double averageGrade = ClasseViva.getAverageGrade(grades);

        return ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            foregroundColor: ThemeManager.isLightTheme(context)
              ? Colors.black
              : Colors.white,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: CircularProgressIndicator(
                    value: averageGrade != -1
                      ? averageGrade / 10
                      : 1,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      averageGrade != -1
                        ? ClasseViva.getGradeColor(ClasseVivaGrade(
                            subject: "",
                            grade: averageGrade.toStringAsFixed(1),
                            type: "",
                            description: "",
                            date: DateTime.now(),
                          ))
                        : Colors.blue,
                    ),
                  ),
                ),
                Text(
                  averageGrade != -1
                    ? averageGrade.toStringAsFixed(1)
                    : "N/A",
                ),
              ],
            ),
          ),
          title: Text(subject),
          subtitle: previousAverageGrade != -1
            ? _getAverageGradeChangeTextWidget(previousAverageGrade, averageGrade)
            : null,
          children: grades.map((grade) => GradeTile(grade)).toList(),
        );
      },
    );
  }
}