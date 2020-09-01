import 'package:classeviva_lite/classeviva.dart';
import 'package:classeviva_lite/routes/home.dart';
import 'package:classeviva_lite/theme_manager.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeleton_text/skeleton_text.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool _showSpinner = false;

  bool _disableButton = true;

  bool _showPassword = false;

  final _uidController = TextEditingController();
  final _pwdController = TextEditingController();

  final FocusNode _pwdFocusNode = FocusNode();

  void _redirectToHomePage() => Get.offAll(Home());

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'ClasseViva Lite'
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Accedi',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Form(
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (value) => _pwdFocusNode.requestFocus(),
                          autofillHints: [ AutofillHints.username, AutofillHints.email ],
                          readOnly: _showSpinner,
                          autocorrect: false,
                          controller: _uidController,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(),
                            labelText: 'Codice personale / Email / Badge',
                          ),
                          onChanged: (value) {
                            setState(() {
                              _disableButton = _uidController.text.isEmpty || _pwdController.text.isEmpty;
                            });
                          },
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          textInputAction: TextInputAction.done,
                          focusNode: _pwdFocusNode,
                          autofillHints: [ AutofillHints.password ],
                          readOnly: _showSpinner,
                          autocorrect: false,
                          controller: _pwdController,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(),
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                            )
                          ),
                          obscureText: !_showPassword,
                          onChanged: (value) {
                            setState(() {
                              _disableButton = _uidController.text.isEmpty || _pwdController.text.isEmpty;
                            });
                          },
                        ),
                        SizedBox(
                          height: 15,
                        ),

                        if (_showSpinner)
                          Spinner(),

                        if (!_showSpinner)
                          Container(
                            width: double.infinity,
                            child: FlatButton(
                              color: ThemeManager.isLightTheme(context)
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).accentColor,
                              colorBrightness: ThemeManager.isLightTheme(context)
                                ? Brightness.dark
                                : Brightness.light,
                              disabledColor: Theme.of(context).disabledColor,
                              padding: EdgeInsets.all(15),
                              child: Icon(
                                Icons.check,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                              ),
                              onPressed: _disableButton ? null : () async {
                                setState(() {
                                  _showSpinner = true;
                                });

                                await ClasseViva
                                  .createSession(_uidController.text, _pwdController.text)
                                  .then((session) => _redirectToHomePage(),
                                  onError: (error) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                            "Errore",
                                          ),
                                          content: Text(
                                            (error is List)
                                              ? error.join("\n")
                                              : error.toString(),
                                          ),
                                        );
                                      },
                                    );
                                  })
                                  .whenComplete(() {
                                    setState(() {
                                      _showSpinner = false;
                                    });
                                  });
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  FutureBuilder<List<ClasseVivaSession>>(
                    future: ClasseViva.getAllSessions(),
                    builder: (context, sessions) {
                      if (!sessions.hasData || sessions.data.isEmpty) return Container();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            'Scegli un account',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
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
                                await ClasseViva
                                  .getAllSessions()
                                  .then((sessions) =>
                                    sessions.forEach((session) => session.signOut())
                                  );

                                setState(() {});

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
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        subtitle: Text(
                                          "${snapshot.data.school} (${session.getYear()}/${session.getYear() + 1})",
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                        onTap: () {
                                          ClasseViva.setCurrentSession(sessions.data[index]);

                                          _redirectToHomePage();
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}