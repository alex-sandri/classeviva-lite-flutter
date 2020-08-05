import 'package:classeviva_lite/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Grades extends StatefulWidget {
  @override
  _GradesState createState() => _GradesState();
}

class _GradesState extends State<Grades> {
  List<ClasseVivaGrade> _grades;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: () async {
        final SharedPreferences preferences = await SharedPreferences.getInstance();

        return ClasseViva(
          sessionId: preferences.getString("sessionId"),
          context: context
        );
      }.call(),
      builder: (context, AsyncSnapshot<ClasseViva> session) {
        if (!session.hasData)
          return Container(
            color: Theme.of(context).primaryColor,
          );

        Future<void> _handleRefresh() async
        {
          final List<ClasseVivaGrade> grades = await session.data.getGrades();

          setState(() {
            _grades = grades;
          });
        }

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
                      child: FutureBuilder(
                        future: _handleRefresh(),
                        builder: (context, snap) {
                          if (_grades == null)
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
                              ),
                            );

                          return RefreshIndicator(
                            onRefresh: _handleRefresh,
                            color: Theme.of(context).primaryColor,
                            child: ListView.builder(
                              shrinkWrap: true,
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
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}