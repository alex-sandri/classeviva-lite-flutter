import 'package:classeviva_lite/classeviva.dart';
import 'package:classeviva_lite/theme_manager.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Grades extends StatefulWidget {
  @override
  _GradesState createState() => _GradesState();
}

class _GradesState extends State<Grades> {
  ClasseViva _session;

  List<ClasseVivaGrade> _grades;

  Map<String, List<ClasseVivaGrade>> _subjects;

  List<ClasseVivaGradesPeriod> _periods = [];

  Future<void> _handleRefresh() async {
    final List<ClasseVivaGrade> grades = await _session.getGrades();

    _subjects = groupBy(grades, (ClasseVivaGrade grade) => grade.subject);

    grades.sort((a, b) {
      // Most recent first
      return b.date.compareTo(a.date);
    });

    if (mounted)
      setState(() {
        _grades = grades;
      });

    final List<ClasseVivaGradesPeriod> periods = await _session.getPeriods();

    if (mounted)
      setState(() {
        _periods = periods;
      });
  }

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
        fontWeight: FontWeight.w900,
      ),
    );
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
      child: DefaultTabController(
        length: 2 + _periods.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Valutazioni'
            ),
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
              GradesView(
                session: _session,
                grades: _grades,
                refreshHandler: _handleRefresh,
                childBuilder: () {
                  return ListView.builder(
                    itemCount: _grades.length + 1,
                    itemBuilder: (context, index) {
                      if (_grades.isEmpty)
                        return SelectableText(
                          "Non sono presenti valutazioni",
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                          ),
                          textAlign: TextAlign.center,
                        );

                      if (index == _grades.length) return Container();

                      final ClasseVivaGrade grade = _grades[index];

                      return GradeTile(grade);
                    },
                  );
                },
              ),
              GradesView(
                session: _session,
                grades: _grades,
                refreshHandler: _handleRefresh,
                childBuilder: () {
                  return ListView.builder(
                    itemCount: _subjects.length + 1,
                    itemBuilder: (context, index) {
                      if (_subjects.isEmpty)
                        return SelectableText(
                          "Non sono presenti valutazioni",
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                          ),
                          textAlign: TextAlign.center,
                        );
                      else if (index == 0)
                        return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Media Totale",
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontWeight: FontWeight.w900,
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
                                        value: ClasseViva.getAverageGrade(_subjects.values.expand((element) => element).toList()) / 10,
                                        valueColor: AlwaysStoppedAnimation<Color>(ClasseViva.getGradeColor(ClasseVivaGrade(
                                          subject: "",
                                          grade: ClasseViva.getAverageGrade(_subjects.values.expand((element) => element).toList()).toStringAsFixed(1),
                                          type: "",
                                          description: "",
                                          date: DateTime.now(),
                                        ))),
                                      ),
                                    ),
                                    Text(
                                      ClasseViva.getAverageGrade(_subjects.values.expand((element) => element).toList()).toStringAsFixed(1),
                                      style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );

                      final String subject = _subjects.keys.elementAt(index - 1);
                      final List<ClasseVivaGrade> grades = _subjects.values.elementAt(index - 1);

                      final List<ClasseVivaGrade> gradesValidForAverageCount = ClasseViva.getGradesValidForAverageCount(grades);

                      final ClasseVivaGrade lastGrade = gradesValidForAverageCount.first;

                      final double previousAverageGrade = ClasseViva.getAverageGrade(gradesValidForAverageCount.where((grade) => grade != lastGrade).toList());
                      final double averageGrade = ClasseViva.getAverageGrade(grades);

                      return Card(
                        child: ExpansionTile(
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
                          title: Text(
                            subject,
                            style: TextStyle(
                              color: ThemeManager.isLightTheme(context)
                                ? Colors.black
                                : Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          subtitle: previousAverageGrade != -1
                            ? _getAverageGradeChangeTextWidget(previousAverageGrade, averageGrade)
                            : null,
                          children: grades.map((grade) => GradeTile(grade)).toList(),
                        ),
                      );
                    },
                  );
                },
              ),
              ..._periods.map((period) {
                return GradesView(
                  session: _session,
                  grades: period.grades,
                  refreshHandler: _handleRefresh,
                  childBuilder: () {
                    final Map<String, List<ClasseVivaGrade>> subjects = groupBy(period.grades, (ClasseVivaGrade grade) => grade.subject);

                    return ListView.builder(
                      itemCount: subjects.length + 1,
                      itemBuilder: (context, index) {
                        if (subjects.isEmpty)
                          return SelectableText(
                            "Non sono presenti valutazioni",
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                            ),
                            textAlign: TextAlign.center,
                          );
                        else if (index == 0)
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Media ${period.name}",
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontWeight: FontWeight.w900,
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
                                        color: Theme.of(context).accentColor,
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

                        grades.sort((a, b) {
                          // Most recent first
                          return b.date.compareTo(a.date);
                        });

                        final List<ClasseVivaGrade> gradesValidForAverageCount = ClasseViva.getGradesValidForAverageCount(grades);

                        final ClasseVivaGrade lastGrade = gradesValidForAverageCount.first;

                        final double previousAverageGrade = ClasseViva.getAverageGrade(gradesValidForAverageCount.where((grade) => grade != lastGrade).toList());
                        final double averageGrade = ClasseViva.getAverageGrade(grades);

                        return Card(
                          child: ExpansionTile(
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
                                    style: TextStyle(
                                      color: ThemeManager.isLightTheme(context)
                                        ? Colors.black
                                        : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            title: Text(
                              subject,
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            subtitle: previousAverageGrade != -1
                              ? _getAverageGradeChangeTextWidget(previousAverageGrade, averageGrade)
                              : null,
                            children: grades.map((grade) => GradeTile(grade)).toList(),
                          ),
                        );
                      },
                    );
                  },
                );
              }),
            ]
          ),
        ),
      ),
    );
  }
}

class GradesView extends StatelessWidget {
  final ClasseViva session;

  final List<ClasseVivaGrade> grades;

  final Widget Function() childBuilder;

  final Future<void> Function() refreshHandler;

  GradesView({
    @required this.session,
    @required this.grades,
    @required this.childBuilder,
    @required this.refreshHandler,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        color: Theme.of(context).brightness == Brightness.light
          ? Theme.of(context).primaryColor
          : null,
        width: double.infinity,
        child: session == null
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: refreshHandler,
                    color: Theme.of(context).primaryColor,
                    child: grades == null
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
                          ),
                        )
                      : childBuilder(),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

class GradeTile extends StatelessWidget {
  final ClasseVivaGrade grade;

  GradeTile(this.grade);

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
        foregroundColor: ThemeManager.isLightTheme(context)
          ? Colors.black
          : Colors.white,
        radius: 25,
      ),
      title: SelectableText(
        grade.subject,
        style: TextStyle(
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SelectableText(
                DateFormat.yMMMMd().format(grade.date),
              ),
              Expanded(
                child: SelectableText(
                  " - ${grade.type}",
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