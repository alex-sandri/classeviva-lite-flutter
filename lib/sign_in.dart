import 'package:classeviva_lite/classeviva.dart';
import 'package:classeviva_lite/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool _showSpinner = false;
  bool _disableButton = true;

  final _uidController = TextEditingController();
  final _pwdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
            width: double.infinity,
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
                          autofillHints: [ AutofillHints.username, AutofillHints.email ],
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
                          autofillHints: [ AutofillHints.password ],
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
                          Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
                            ),
                          ),
                        if (!_showSpinner)
                          Container(
                            width: double.infinity,
                            child: FlatButton(
                              color: Theme.of(context).accentColor,
                              disabledColor: Theme.of(context).disabledColor,
                              padding: EdgeInsets.all(15),
                              child: Icon(
                                Icons.check,
                                color: Theme.of(context).primaryColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                              ),
                              onPressed: _disableButton ? null : () async {
                                setState(() {
                                  _showSpinner = true;
                                });

                                await ClasseViva
                                  .createSession(_uidController.text, _pwdController.text, context)
                                  .then((session) async {
                                    final SharedPreferences preferences = await SharedPreferences.getInstance();

                                    await preferences.setString("sessionId", session.sessionId);

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Home(),
                                      ),
                                      (route) => false
                                    );
                                  },
                                  onError: (errors) {
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