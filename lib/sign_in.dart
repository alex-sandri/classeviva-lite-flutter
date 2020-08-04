import 'package:classeviva_lite/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool _showSpinner = false;

  @override
  Widget build(BuildContext context) {
    final _uidController = TextEditingController();
    final _pwdController = TextEditingController();

    OutlineInputBorder _inputDecoration() {
      return OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).accentColor,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      );
    }

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
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Form(
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          readOnly: _showSpinner,
                          autocorrect: false,
                          controller: _uidController,
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                          ),
                          decoration: InputDecoration(
                            enabledBorder: _inputDecoration(),
                            focusedBorder: _inputDecoration(),
                            labelText: 'Codice personale / Email / Badge',
                            labelStyle: TextStyle(
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                          cursorColor: Theme.of(context).accentColor,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          readOnly: _showSpinner,
                          autocorrect: false,
                          controller: _pwdController,
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                          ),
                          decoration: InputDecoration(
                            enabledBorder: _inputDecoration(),
                            focusedBorder: _inputDecoration(),
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                          cursorColor: Theme.of(context).accentColor,
                          obscureText: true,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        if (_showSpinner)
                          Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
                            ),
                          ),
                        if (!_showSpinner)
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).accentColor,
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                            ),
                            child: OutlineButton(
                              borderSide: BorderSide(
                                color: Theme.of(context).accentColor,
                                width: 2,
                              ),
                              highlightedBorderColor: Theme.of(context).accentColor,
                              padding: EdgeInsets.all(15),
                              child: Icon(
                                Icons.check,
                                color: Theme.of(context).primaryColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                              ),
                              onPressed: () async {
                                setState(() {
                                  _showSpinner = true;
                                });

                                await ClasseViva
                                  .createSession(_uidController.text, _pwdController.text)
                                  .catchError((errors) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                            "Errore",
                                          ),
                                          content: Text(
                                            (errors as List<dynamic>).join("\n"),
                                          ),
                                        );
                                      },
                                    );
                                  })
                                  .then((session) async {
                                    final SharedPreferences preferences = await SharedPreferences.getInstance();

                                    await preferences.setString("sessionId", session.sessionId);
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
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}