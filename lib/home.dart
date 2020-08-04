import 'package:classeviva_lite/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: () async {
        final SharedPreferences preferences = await SharedPreferences.getInstance();

        return ClasseViva(preferences.getString("sessionId"));
      }.call(),
      builder: (context, AsyncSnapshot<ClasseViva> session) {
        if (!session.hasData)
          return Container(
            color: Theme.of(context).primaryColor,
          );

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
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}