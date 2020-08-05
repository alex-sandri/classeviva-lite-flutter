import 'package:classeviva_lite/home.dart';
import 'package:classeviva_lite/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xffcc1020),
      ),
    );

    return MaterialApp(
      title: 'ClasseViva Lite',
      theme: ThemeData(
        primaryColor: Color(0xffcc1020),
        accentColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, AsyncSnapshot<SharedPreferences> preferences) {
          if (!preferences.hasData)
            return Container(
              color: Theme.of(context).primaryColor,
            );

          return preferences.data.getString("sessionId") != null ? Home() : SignIn();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
