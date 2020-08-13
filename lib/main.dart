import 'package:classeviva_lite/classeviva.dart';
import 'package:classeviva_lite/home.dart';
import 'package:classeviva_lite/sign_in.dart';
import 'package:classeviva_lite/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  FlutterDownloader.initialize(debug: false);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
      ],
      child: MyApp(),
    )
  );
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
        brightness: Brightness.light,
        primaryColor: Color(0xffcc1020),
        accentColor: Colors.white,
        appBarTheme: AppBarTheme(
          color: Color(0xffcc1020),
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: Colors.transparent,
        ),
        dividerTheme: DividerThemeData(
          color: Colors.black,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black87,
        accentColor: Colors.white,
        appBarTheme: AppBarTheme(
          color: Color(0xffcc1020),
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: Colors.transparent,
        ),
        dividerTheme: DividerThemeData(
          color: Colors.white,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: Provider.of<ThemeManager>(context).themeMode,
      home: FutureBuilder(
        future: ClasseViva.isSignedIn(),
        builder: (context, AsyncSnapshot<bool> isSignedIn) {
          if (!isSignedIn.hasData)
            return Container(
              color: Theme.of(context).primaryColor,
            );

          return isSignedIn.data ? Home() : SignIn();
        },
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale("it", "IT"),
      ],
    );
  }
}
