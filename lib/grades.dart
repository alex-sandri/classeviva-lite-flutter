import 'package:classeviva_lite/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Grades extends StatefulWidget {
  @override
  _GradesState createState() => _GradesState();
}

class _GradesState extends State<Grades> {
  ClasseViva _session;

  List<ClasseVivaGrade> _grades;

  Future<void> _handleRefresh() async {
    final List<ClasseVivaGrade> grades = await _session.getGrades();

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
    if (_session == null)
      return Container(
        color: Theme.of(context).primaryColor,
      );

    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Valutazioni'
          ),
          elevation: 0,
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            color: Theme.of(context).primaryColor,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: Theme.of(context).primaryColor,
                    child: _grades == null
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _grades.length,
                          itemBuilder: (context, index) {
                            final ClasseVivaGrade grade = _grades[index];

                            Color _getGradeColor(ClasseVivaGrade grade)
                            {
                              Color color;

                              if (grade.type != "Voto Test")
                              {
                                double parsedGrade;

                                if (grade.grade.contains("½")) parsedGrade = double.parse(grade.grade.replaceAll("½", ".5"));
                                else if (grade.grade.contains("+")) parsedGrade = double.parse(grade.grade.replaceAll("+", ".25"));
                                else if (grade.grade.contains("-")) parsedGrade = double.parse(grade.grade.replaceAll("-", ".75")) - 1;

                                if (parsedGrade == null) color = Colors.blue; // Letter instead of a number, TODO: parse grade letters
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
                              title: Text(
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
                                      Text(
                                        DateFormat.yMMMMd().format(grade.date),
                                        style: TextStyle(
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          " - ${grade.type}".replaceAllMapped(RegExp(".{1}"), (match) => "\u{200b}${match.group(0)}"),
                                          style: TextStyle(
                                            color: Theme.of(context).accentColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    grade.description,
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                    ),
                                  ),
                                ],
                              )
                            );
                          },
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}