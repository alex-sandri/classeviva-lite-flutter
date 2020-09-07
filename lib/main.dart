import 'package:classeviva_lite/authentication_manager.dart';
import 'package:classeviva_lite/classeviva.dart';
import 'package:classeviva_lite/routes/home.dart';
import 'package:classeviva_lite/routes/sign_in.dart';
import 'package:classeviva_lite/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await FlutterDownloader.initialize(debug: false);

  await Hive.initFlutter();

  await Hive.openBox("preferences");

  Widget home;

  if (AuthenticationManager.isAuthenticationEnabled)
  {
    bool didAuthenticate = await AuthenticationManager.authenticate();

    if (!didAuthenticate) home = SignIn();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
      ],
      child: MyApp(
        home: home,
      ),
    )
  );
}

class MyApp extends StatelessWidget {
  final Widget home;

  MyApp({
    this.home,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: ClasseViva.PRIMARY_LIGHT,
      ),
    );

    return GetMaterialApp(
      title: 'ClasseViva Lite',
      theme: ThemeData.light().copyWith(
        brightness: Brightness.light,
        primaryColor: ClasseViva.PRIMARY_LIGHT,
        accentColor: Colors.white,
        appBarTheme: AppBarTheme(
          color: ClasseViva.PRIMARY_LIGHT,
          elevation: 0,
        ),
        tabBarTheme: TabBarTheme(
          indicator: UnderlineTabIndicator(),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark().copyWith(
        brightness: Brightness.dark,
        primaryColor: Colors.black87,
        accentColor: Colors.white,
        appBarTheme: AppBarTheme(
          color: ClasseViva.PRIMARY_LIGHT,
          elevation: 0,
        ),
        tabBarTheme: TabBarTheme(
          indicator: UnderlineTabIndicator(),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: Provider.of<ThemeManager>(context).themeMode,
      home: this.home ?? (ClasseViva.isSignedIn() ? Home() : SignIn()),
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
