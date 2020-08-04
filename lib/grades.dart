import 'package:classeviva_lite/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Grades extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: () async {
        final SharedPreferences preferences = await SharedPreferences.getInstance();

        return ClasseViva(preferences.getString("sessionId"));
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
                'ClasseViva Lite'
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
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FutureBuilder(
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

                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(grade.grade),
                                ),
                                title: Text(grade.subject),
                                subtitle: Text(grade.description),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}