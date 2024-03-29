import 'package:classeviva_lite/miscellaneous/authentication_manager.dart';
import 'package:classeviva_lite/miscellaneous/cache_manager.dart';
import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaProfile.dart';
import 'package:classeviva_lite/routes/Home.dart';
import 'package:classeviva_lite/routes/SignIn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeleton_text/skeleton_text.dart';

class SessionsList extends StatefulWidget {
  final ScrollPhysics physics;

  final bool shrinkWrap;

  final EdgeInsets padding;

  SessionsList({
    this.physics,
    this.shrinkWrap = false,
    this.padding = const EdgeInsets.all(15),
  });

  @override
  _SessionsListState createState() => _SessionsListState();
}

class _SessionsListState extends State<SessionsList> {
  final List<ClasseVivaSession> _sessions = ClasseViva.getAllSessions();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      children: <Widget>[
        if (_sessions.isNotEmpty)
          Container(
            width: double.infinity,
            child: TextButton(
              child: Text(
                "Esci da tutte le sessioni"
              ),
              onPressed: () async {
                for (int i = 0; i < _sessions.length; i++)
                  await _sessions[i].signOut();

                await CacheManager.empty();

                Get.offAll(SignIn());
              },
            ),
          ),

        SizedBox(
          height: 15,
        ),
        ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          separatorBuilder: (context, index) => Divider(),
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

                return Dismissible(
                  key: ValueKey(_sessions[index]),
                  onDismissed: (direction) async {
                    final bool isCurrentSession = ClasseViva.isSignedIn() && ClasseViva.getCurrentSession().id == _sessions[index].id;

                    await _sessions[index].signOut();

                    _sessions.removeAt(index);

                    ScaffoldMessenger
                      .of(context)
                      .showSnackBar(SnackBar(content: Text("Sessione rimossa")));

                    if (isCurrentSession)
                    {
                      await CacheManager.empty();

                      Get.offAll(SignIn());
                    }
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
                        await CacheManager.empty();

                        await ClasseViva.setCurrentSession(_sessions[index]);

                        Get.offAll(Home());
                      }
                    },
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