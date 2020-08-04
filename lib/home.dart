import 'package:classeviva_lite/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatelessWidget {
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
                        future: session.data.getProfile(),
                        builder: (context, AsyncSnapshot<ClasseVivaProfile> profile) {
                          if (!profile.hasData)
                            return CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
                            );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                profile.data.name,
                                style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                              Text(
                                profile.data.school,
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      ListView(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
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
                              onTap: () {},
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
                              onTap: () {},
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
                              onTap: () {},
                            ),
                          ),
                        ],
                      )
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