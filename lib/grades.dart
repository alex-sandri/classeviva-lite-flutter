import 'package:classeviva_lite/classeviva.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Grades extends StatefulWidget {
  @override
  _GradesState createState() => _GradesState();
}

class _GradesState extends State<Grades> {
  ClasseViva _session;

  List<ClasseVivaGrade> _grades;

  Map<String, List<ClasseVivaGrade>> _subjects;

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
  }

  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((preferences) {
      _session = ClasseViva(
        sessionId: preferences.getString("sessionId"),
        context: context
      );

      _handleRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Valutazioni'
            ),
            elevation: 0,
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.grade),
                  text: "Ultime Valutazioni",
                ),
                Tab(
                  icon: Icon(Icons.assessment),
                  text: "Riepilogo",
                ),
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

                      return ListTile(
                        isThreeLine: true,
                        leading: CircleAvatar(
                          child: Text(
                            grade.grade,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          backgroundColor: ClasseViva.getGradeColor(grade),
                          radius: 25,
                        ),
                        title: SelectableText(
                          grade.subject,
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
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
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                                Expanded(
                                  child: SelectableText(
                                    " - ${grade.type}",
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                            SelectableLinkify(
                              text: grade.description,
                              options: LinkifyOptions(humanize: false),
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                              ),
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

                      if (index == _subjects.length) return Container();

                      final String subject = _subjects.keys.elementAt(index);
                      final List<ClasseVivaGrade> grades = _subjects.values.elementAt(index);

                      double _getAverageGrade(List<ClasseVivaGrade> grades)
                      {
                        // Grades with "Voto Test" type can't be included in the average
                        final List<ClasseVivaGrade> gradesValidForAverageCount = grades.where((grade) => grade.type != "Voto Test").toList();

                        return gradesValidForAverageCount
                          .map((grade) => ClasseViva.getGradeValue(grade.grade))
                          .reduce((a, b) => a + b) / gradesValidForAverageCount.length;
                      }

                      return ListTile(
                        leading: SizedBox(
                          width: 50,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Center(
                                child: CircularProgressIndicator(
                                  value: _getAverageGrade(grades) / 10,
                                  valueColor: AlwaysStoppedAnimation<Color>(ClasseViva.getGradeColor(ClasseVivaGrade(
                                    subject: "",
                                    grade: _getAverageGrade(grades).toStringAsFixed(1),
                                    type: "",
                                    description: "",
                                    date: DateTime.now(),
                                  ))),
                                ),
                              ),
                              Text(
                                _getAverageGrade(grades).toStringAsFixed(1),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        title: SelectableText(
                          subject,
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      );
                    },
                  );
                },
              )
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
        color: Theme.of(context).primaryColor,
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