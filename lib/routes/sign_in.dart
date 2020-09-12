import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/routes/home.dart';
import 'package:classeviva_lite/miscellaneous/theme_manager.dart';
import 'package:classeviva_lite/widgets/sessions_list.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignIn extends StatefulWidget {
  final bool showAccountChooser;

  SignIn({
    this.showAccountChooser = true,
  });

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
            "Accedi"
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: ListView(
            padding: const EdgeInsets.all(15),
            children: <Widget>[
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

              if (widget.showAccountChooser)
                SessionsList(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
            ],
          ),
        ),
      ),
    );
  }
}