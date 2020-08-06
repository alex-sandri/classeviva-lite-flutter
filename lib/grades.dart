import 'package:classeviva_lite/classeviva.dart';
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

  Future<void> _handleRefresh() async {
    final List<ClasseVivaGrade> grades = await _session.getGrades();

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

                      Color _getGradeColor(ClasseVivaGrade grade)
                      {
                        Color color;

                        // IMPORTANT: These are not accurate at all, I just guessed what their equivalents are (but they somehow seem reasonable)
                        // I just incremented them by 0.25, except for the 'ns/s' which was incremented by 0.5
                        Map<String, String> reGrades = {
                          // Non sufficiente
                          "ns": "5",
                          // Non sufficiente/Sufficiente
                          "ns/s": "5.5",
                          // Quasi sufficiente
                          "qs": "6-",
                          // Sufficiente
                          "s": "6",
                          // Più che sufficiente
                          "ps": "6+",
                          // Sufficiente/Discreto
                          "s/dc": "6.5",
                          // Quasi discreto
                          "qd": "7-",
                          // Discreto
                          "dc": "7",
                          // Più che discreto
                          "pdc": "7+",
                          // Discreto/Buono
                          "dc/b": "7.5",
                          // Quasi buono
                          "qb": "8-",
                          // Buono
                          "b": "8",
                          // Più che buono
                          "pb": "8+",
                          // Buono/Distinto
                          "b/d": "8.5",
                          // Quasi distinto
                          "qdn": "9-",
                          // Molto?
                          "m": "9",
                          // Distinto
                          "ds": "9",
                          // Più che distinto
                          "pdn": "9+",
                          // Distinto/Ottimo
                          "d/o": "9.5",
                          // Quasi ottimo
                          "qo": "10-",
                          // Ottimo
                          "o": "10",
                        };

                        if (grade.type != "Voto Test")
                        {
                          double parsedGrade = double.tryParse(grade.grade);

                          if (grade.grade.contains("½")) parsedGrade = double.parse(grade.grade.replaceAll("½", ".5"));
                          else if (grade.grade.contains("+")) parsedGrade = double.parse(grade.grade.replaceAll("+", ".25"));
                          else if (grade.grade.contains("-")) parsedGrade = double.parse(grade.grade.replaceAll("-", ".75")) - 1;

                          if (parsedGrade == null)
                          {
                            if (RegExp("^${reGrades.keys.join("|")}\$").hasMatch(grade.grade))
                            {
                              grade.grade = reGrades[grade.grade];

                              color = _getGradeColor(grade);
                            }
                            else color = Colors.blue;
                          }
                          else if (parsedGrade >= 6) color = Colors.green;
                          else if (parsedGrade >= 5) color = Colors.orange;
                          else color = Colors.red;
                        }
                        else color = Colors.blue;

                        return color; 
                      }

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
                          backgroundColor: _getGradeColor(grade),
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
                    itemCount: _grades.length,
                    itemBuilder: (context, index) {
                      return ListTile(

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