import 'package:classeviva_lite/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Grades extends StatelessWidget {
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
                        future: session.data.getGrades(),
                        builder: (context, AsyncSnapshot<List<ClasseVivaGrade>> grades) {
                          if (!grades.hasData)
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
                              ),
                            );

                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: grades.data.length,
                            itemBuilder: (context, index) {
                              final ClasseVivaGrade grade = grades.data[index];

                              Color _getGradeColor(ClasseVivaGrade grade)
                              {
                                Color color;

                                if (grade.type != "Voto Test")
                                {
                                  final int parsedGrade = int.tryParse(grade.grade);

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