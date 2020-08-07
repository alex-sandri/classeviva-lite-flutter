import 'package:classeviva_lite/absences.dart';
import 'package:classeviva_lite/agenda.dart';
import 'package:classeviva_lite/attachments.dart';
import 'package:classeviva_lite/classeviva.dart';
import 'package:classeviva_lite/demerits.dart';
import 'package:classeviva_lite/grades.dart';
import 'package:classeviva_lite/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_text/skeleton_text.dart';

class Home extends StatelessWidget {
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
                'ClasseViva Lite'
              ),
              elevation: 0,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () async {
                    final SharedPreferences preferences = await SharedPreferences.getInstance();

                    await preferences.remove("sessionId");

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignIn(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
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
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: FutureBuilder(
                        future: session.data.getProfile(),
                        builder: (context, AsyncSnapshot<ClasseVivaProfile> profile) {
                          if (!profile.hasData)
                            return SkeletonAnimation(
                              shimmerColor: Colors.white54,
                              gradientColor: Color.fromARGB(0, 244, 244, 244),
                              curve: Curves.fastOutSlowIn,
                              child: Container(  
                                width: double.infinity,  
                                height: 57, // Horrible but it works (height of the column below)
                                decoration: BoxDecoration(  
                                  color: Theme.of(context).disabledColor,  
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SelectableText(
                                profile.data.name,
                                style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                              SelectableText(
                                profile.data.school,
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        children: <Widget>[
                          Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.grade,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: Text(
                                "Valutazioni",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Grades(),
                                  )
                                );
                              },
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.watch_later,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: Text(
                                "Assenze / Ritardi",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Absences(),
                                  )
                                );
                              },
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.bookmark_border,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: Text(
                                "Bacheca",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              onTap: () {},
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.book,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: Text(
                                "Lezioni",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              onTap: () {},
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.view_agenda,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: Text(
                                "Agenda & Compiti",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Agenda(),
                                  )
                                );
                              },
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.attachment,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: Text(
                                "Didattica",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Attachments(),
                                  )
                                );
                              },
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.note,
                                color: Theme.of(context).primaryColor,
                              ),
                              title: Text(
                                "Note",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Demerits(),
                                  )
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
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