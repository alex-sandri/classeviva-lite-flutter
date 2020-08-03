import 'package:flutter/material.dart';

class SignIn extends StatelessWidget {
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
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).accentColor,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.check),
                            color: Theme.of(context).primaryColor,
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