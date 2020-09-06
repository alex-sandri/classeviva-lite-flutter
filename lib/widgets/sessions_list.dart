import 'package:classeviva_lite/classeviva.dart';
import 'package:classeviva_lite/routes/home.dart';
import 'package:classeviva_lite/routes/sign_in.dart';
import 'package:classeviva_lite/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeleton_text/skeleton_text.dart';

class SessionsList extends StatefulWidget {
  @override
  _SessionsListState createState() => _SessionsListState();
}

class _SessionsListState extends State<SessionsList> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(15),
      children: <Widget>[
        FutureBuilder<List<ClasseVivaSession>>(
          future: ClasseViva.getAllSessions(),
          builder: (context, sessions) {
            if (!sessions.hasData || sessions.data.isEmpty) return Container();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  child: FlatButton(
                    color: ThemeManager.isLightTheme(context)
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).accentColor,
                    colorBrightness: ThemeManager.isLightTheme(context)
                      ? Brightness.dark
                      : Brightness.light,
                    padding: EdgeInsets.all(15),
                    child: Text(
                      "Esci da tutte le sessioni"
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    onPressed: () async {
                      for (int i = 0; i < sessions.data.length; i++)
                        await sessions.data[i].signOut();

                      Get.offAll(SignIn());
                    },
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: sessions.data.length,
                  itemBuilder: (context, index) {
                    final ClasseViva session = ClasseViva(sessions.data[index]);

                    return FutureBuilder<ClasseVivaProfile>(
                      future: session.getProfile(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: SkeletonAnimation(
                              shimmerColor: Colors.white54,
                              gradientColor: Color.fromARGB(0, 244, 244, 244),
                              curve: Curves.fastOutSlowIn,
                              child: Container(  
                                width: double.infinity,  
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).disabledColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          );

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          child: Dismissible(
                            key: ValueKey(sessions.data[index]),
                            onDismissed: (direction) async {
                              final bool isCurrentSession = await ClasseViva.isSignedIn() && (await ClasseViva.getCurrentSession()).id == sessions.data[index].id;

                              await sessions.data[index].signOut();

                              sessions.data.removeAt(index);

                              Scaffold
                                .of(context)
                                .showSnackBar(SnackBar(content: Text("Sessione rimossa")));

                              if (isCurrentSession) Get.offAll(SignIn());
                              else setState(() {});
                            },
                            background: Container(
                              color: Colors.red,
                              child: Icon(
                                Icons.exit_to_app,
                                color: Colors.white,
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                snapshot.data.name,
                              ),
                              subtitle: Text(
                                "${snapshot.data.school} (${session.getYear()}/${session.getYear() + 1})",
                              ),
                              leading: snapshot.data.avatar,
                              onTap: () async {
                                await ClasseViva.setCurrentSession(sessions.data[index]);

                                Get.offAll(Home());
                              },
                            ),
                          ),
                        );
                      }
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}