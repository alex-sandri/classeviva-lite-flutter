import 'package:classeviva_lite/classeviva.dart';
import 'package:classeviva_lite/home.dart';
import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';

class SignIn extends StatefulWidget {
  final String _year;

  @override
  _SignInState createState() => _SignInState();

  SignIn([ this._year = "" ]);
}

class _SignInState extends State<SignIn> {
  bool _showSpinner = false;

  bool _disableButton = true;

  bool _showPassword = false;

  final _uidController = TextEditingController();
  final _pwdController = TextEditingController();

  void _redirectToHomePage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => Home(),
      ),
      (route) => false
    );
  }

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
            height: double.infinity,
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
                        color: Theme.of(context).accentColor,
                      ),
                    ),

                    if (widget._year != "")
                      Text(
                        'all\'anno 20${widget._year}',
                        style: TextStyle(
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
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                ),
                                color: Theme.of(context).accentColor,
                                onPressed: () {
                                  setState(() {
                                    _showPassword = !_showPassword;
                                  });
                                },
                              )
                            ),
                            cursorColor: Theme.of(context).accentColor,
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
                                    .createSession(_uidController.text, _pwdController.text, context, widget._year)
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
                                color: Theme.of(context).accentColor,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: sessions.data.length,
                              itemBuilder: (context, index) {
                                final ClasseViva session = ClasseViva(
                                  session: sessions.data[index],
                                  context: context,
                                );

                                return FutureBuilder<ClasseVivaProfile>(
                                  future: session.getProfile(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData)
                                      return Padding(
                                        padding: EdgeInsets.all(4),
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
                                      color: Colors.transparent,
                                      child: ListTile(
                                        title: Text(
                                          snapshot.data.name,
                                          style: TextStyle(
                                            color: Theme.of(context).accentColor,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        subtitle: Text(
                                          "${snapshot.data.school} (${session.getYear()}/${session.getYear() + 1})",
                                          style: TextStyle(
                                            color: Theme.of(context).accentColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                        onTap: () {
                                          ClasseViva.setCurrentSession(sessions.data[index]);

                                          _redirectToHomePage();
                                        },
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
      ),
    );
  }
}