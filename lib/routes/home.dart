import 'package:classeviva_lite/models/ClasseVivaBasicProfile.dart';
import 'package:classeviva_lite/models/ClasseVivaProfile.dart';
import 'package:classeviva_lite/routes/about.dart';
import 'package:classeviva_lite/routes/absences.dart';
import 'package:classeviva_lite/routes/agenda.dart';
import 'package:classeviva_lite/routes/attachments.dart';
import 'package:classeviva_lite/routes/books.dart';
import 'package:classeviva_lite/routes/bulletin_board.dart';
import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/routes/calendar.dart';
import 'package:classeviva_lite/routes/demerits.dart';
import 'package:classeviva_lite/routes/final_grades.dart';
import 'package:classeviva_lite/routes/grades.dart';
import 'package:classeviva_lite/routes/lessons.dart';
import 'package:classeviva_lite/routes/manage_accounts.dart';
import 'package:classeviva_lite/routes/settings.dart';
import 'package:classeviva_lite/routes/sign_in.dart';
import 'package:classeviva_lite/widgets/classeviva_webview.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeleton_text/skeleton_text.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ClasseViva _session = ClasseViva(ClasseViva.getCurrentSession());

  bool _showLoadingSpinner = false;

  @override
  Widget build(BuildContext context) {
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
              tooltip: "Esci",
              onPressed: () async {
                await _session.session.signOut();

                Get.offAll(SignIn());
              },
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: _showLoadingSpinner
            ? Spinner()
            :
              ListView(
                padding: EdgeInsets.all(15),
                children: <Widget>[
                  StreamBuilder<ClasseVivaBasicProfile>(
                    stream: _session.getBasicProfile(),
                    builder: (context, profile) {
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
                            ),
                          ),
                          SelectableText(
                            profile.data.school,
                          ),

                          if (_session.getShortYear() != "")
                            SelectableText(
                              "20${_session.getShortYear()}/20${int.parse(_session.getShortYear()) + 1}",
                            ),
                        ],
                      );
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.today,
                      ),
                      title: Text(
                        "Registro",
                      ),
                      onTap: () => Get.to(Calendar()),
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
                      onTap: () => Get.to(Grades()),
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
                      onTap: () => Get.to(Absences()),
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
                      onTap: () => Get.to(BulletinBoard()),
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
                      onTap: () => Get.to(Lessons()),
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
                      onTap: () => Get.to(Agenda()),
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
                      onTap: () => Get.to(Attachments()),
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
                      onTap: () => Get.to(Demerits()),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.computer,
                      ),
                      title: Text(
                        "Aule Virtuali",
                      ),
                      onTap: () => Get.to(ClasseVivaWebview(
                        session: _session,
                        title: "Aule Virtuali",
                        url: Uri.parse(ClasseVivaEndpoints(_session.getShortYear()).virtualClassrooms()),
                      )),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.group,
                      ),
                      title: Text(
                        "Colloqui",
                      ),
                      onTap: () => Get.to(ClasseVivaWebview(
                        session: _session,
                        title: "Colloqui",
                        url: Uri.parse(ClasseVivaEndpoints(_session.getShortYear()).meetings()),
                      )),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.help,
                      ),
                      title: Text(
                        "Sportello",
                      ),
                      onTap: () => Get.to(ClasseVivaWebview(
                        session: _session,
                        title: "Sportello",
                        url: Uri.parse(ClasseVivaEndpoints(_session.getShortYear()).helpDesk()),
                      )),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.poll,
                      ),
                      title: Text(
                        "Scrutini",
                      ),
                      onTap: () => Get.to(FinalGrades()),
                    ),
                  ),

                  if (_session.getShortYear() == "") // Current year
                    Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.book,
                        ),
                        title: Text(
                          "Libri",
                        ),
                        onTap: () => Get.to(Books()),
                      ),
                    ),
                ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              HomeDrawerHeader(_session),
              ListTile(
                leading: Icon(
                  Icons.skip_previous,
                ),
                title: Text(
                  "Anno Precedente",
                ),
                onTap: () async {
                  Get.back();

                  setState(() {
                    _showLoadingSpinner = true;
                  });

                  await ClasseViva.createSession(
                    _session.session.uid,
                    _session.session.pwd,
                    year: (int.parse(_session.getShortYear(false)) - 1).toString(),
                  );

                  Get.offAll(Home());
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.language,
                ),
                title: Text(
                  "ClasseViva Web",
                ),
                onTap: () => Get.to(ClasseVivaWebview(
                  session: _session,
                  title: "ClasseViva Web",
                  url: Uri.parse(ClasseVivaEndpoints(_session.getShortYear()).baseUrl),
                )),
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.add,
                ),
                title: Text(
                  "Aggiungi account",
                ),
                onTap: () => Get.to(SignIn(showAccountChooser: false)),
              ),
              ListTile(
                leading: Icon(
                  Icons.account_circle,
                ),
                title: Text(
                  "Gestisci account",
                ),
                onTap: () => Get.to(ManageAccounts()),
              ),
              ListTile(
                leading: Icon(
                  Icons.settings,
                ),
                title: Text(
                  "Impostazioni",
                ),
                onTap: () => Get.to(Settings()),
              ),
              ListTile(
                leading: Icon(
                  Icons.info,
                ),
                title: Text(
                  "Informazioni",
                ),
                onTap: () => Get.to(About()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeDrawerHeader extends StatelessWidget {
  final ClasseViva _session;

  HomeDrawerHeader(this._session);

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      child: StreamBuilder<ClasseVivaProfile>(
        stream: _session.getProfile().asBroadcastStream(),
        builder: (context, profile) {
          if (!profile.hasData)
            return Container();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              profile.data.profilePic,
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
              Text(
                "${_session.getYear()}/${_session.getYear() + 1}",
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          );
        },
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.color,
      ),
    );
  }
}