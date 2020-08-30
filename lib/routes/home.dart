import 'package:classeviva_lite/routes/absences.dart';
import 'package:classeviva_lite/routes/agenda.dart';
import 'package:classeviva_lite/routes/attachments.dart';
import 'package:classeviva_lite/routes/bulletin_board.dart';
import 'package:classeviva_lite/classeviva.dart';
import 'package:classeviva_lite/routes/calendar.dart';
import 'package:classeviva_lite/routes/demerits.dart';
import 'package:classeviva_lite/routes/grades.dart';
import 'package:classeviva_lite/routes/lessons.dart';
import 'package:classeviva_lite/routes/settings.dart';
import 'package:classeviva_lite/routes/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: () async {
        return ClasseViva(await ClasseViva.getCurrentSession());
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
                    await session.data.signOut(context);
                  },
                ),
              ],
            ),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Container(
                color: Theme.of(context).brightness == Brightness.light
                  ? Theme.of(context).primaryColor
                  : null,
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
                              
                              if (session.data.getShortYear() != "")
                                SelectableText(
                                  "20${session.data.getShortYear()}/20${int.parse(session.data.getShortYear()) + 1}",
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
                                Icons.today,
                              ),
                              title: Text(
                                "Registro",
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Calendar(),
                                  )
                                );
                              },
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.grade,
                              ),
                              title: Text(
                                "Valutazioni",
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
                              ),
                              title: Text(
                                "Assenze / Ritardi",
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
                              ),
                              title: Text(
                                "Bacheca",
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BulletinBoard(),
                                  )
                                );
                              },
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.book,
                              ),
                              title: Text(
                                "Lezioni",
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Lessons(),
                                  )
                                );
                              },
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.view_agenda,
                              ),
                              title: Text(
                                "Agenda & Compiti",
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
                              ),
                              title: Text(
                                "Didattica",
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
                              ),
                              title: Text(
                                "Note",
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
                          Divider(
                            color: Theme.of(context).accentColor,
                            thickness: 2,
                            indent: 4,
                            endIndent: 4,
                          ),
                          Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.skip_previous,
                              ),
                              title: Text(
                                "Anno Precedente",
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignIn((int.parse(session.data.getShortYear(false)) - 1).toString()),
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
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  FutureBuilder(
                    future: session.data.getProfile(),
                    builder: (context, AsyncSnapshot<ClasseVivaProfile> profile) {
                      if (!profile.hasData)
                        return Container();

                      return DrawerHeader(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.data.name,
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 25,
                              ),
                            ),
                            Text(
                              profile.data.school,
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            if (session.data.getShortYear() != "")
                              Text(
                                "20${session.data.getShortYear()}/20${int.parse(session.data.getShortYear()) + 1}",
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).appBarTheme.color,
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.add,
                    ),
                    title: Text(
                      "Aggiungi Account",
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignIn(),
                        )
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.settings,
                    ),
                    title: Text(
                      "Impostazioni",
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Settings(),
                        )
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}