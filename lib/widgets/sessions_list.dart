import 'package:classeviva_lite/miscellaneous/authentication_manager.dart';
import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaProfile.dart';
import 'package:classeviva_lite/routes/home.dart';
import 'package:classeviva_lite/routes/sign_in.dart';
import 'package:classeviva_lite/miscellaneous/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeleton_text/skeleton_text.dart';

class SessionsList extends StatefulWidget {
  final bool shrinkWrap;

  SessionsList({
    this.shrinkWrap = false,
  });

  @override
  _SessionsListState createState() => _SessionsListState();
}

class _SessionsListState extends State<SessionsList> {
  List<ClasseVivaSession> _sessions;

  @override
  void initState() {
    super.initState();

    _sessions = ClasseViva.getAllSessions();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: widget.shrinkWrap,
      padding: const EdgeInsets.all(15),
      children: <Widget>[
        if (_sessions.isNotEmpty)
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
                for (int i = 0; i < _sessions.length; i++)
                  await _sessions[i].signOut();

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
          itemCount: _sessions.length,
          itemBuilder: (context, index) {
            final ClasseViva session = ClasseViva(_sessions[index]);

            return StreamBuilder<ClasseVivaProfile>(
              stream: session.getProfile(),
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
                    key: ValueKey(_sessions[index]),
                    onDismissed: (direction) async {
                      final bool isCurrentSession = ClasseViva.isSignedIn() && ClasseViva.getCurrentSession().id == _sessions[index].id;

                      await _sessions[index].signOut();

                      _sessions.removeAt(index);

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
                      leading: snapshot.data.avatar.toWidget(),
                      onTap: () async {
                        bool success = AuthenticationManager.isAuthenticationEnabled
                          ? await AuthenticationManager.authenticate()
                          : true;

                        if (success)
                        {
                          ClasseViva.setCurrentSession(_sessions[index]);

                          Get.offAll(Home());
                        }
                      },
                    ),
                  ),
                );
              }
            );
          },
        )
      ],
    );
  }
}