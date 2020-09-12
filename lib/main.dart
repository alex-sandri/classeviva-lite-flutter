import 'package:classeviva_lite/adapters/ColorAdapter.dart';
import 'package:classeviva_lite/adapters/DurationAdapter.dart';
import 'package:classeviva_lite/miscellaneous/authentication_manager.dart';
import 'package:classeviva_lite/miscellaneous/cache_manager.dart';
import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaAbsence.dart';
import 'package:classeviva_lite/models/ClasseVivaAgendaItem.dart';
import 'package:classeviva_lite/models/ClasseVivaBasicProfile.dart';
import 'package:classeviva_lite/models/ClasseVivaCalendar.dart';
import 'package:classeviva_lite/models/ClasseVivaCalendarLesson.dart';
import 'package:classeviva_lite/models/ClasseVivaGrade.dart';
import 'package:classeviva_lite/models/ClasseVivaGradesPeriod.dart';
import 'package:classeviva_lite/models/ClasseVivaProfile.dart';
import 'package:classeviva_lite/models/ClasseVivaProfileAvatar.dart';
import 'package:classeviva_lite/routes/home.dart';
import 'package:classeviva_lite/routes/sign_in.dart';
import 'package:classeviva_lite/miscellaneous/theme_manager.dart';
import 'package:classeviva_lite/widgets/classeviva_webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quick_actions/quick_actions.dart';

void main() async {
  await FlutterDownloader.initialize(debug: false);

  await Hive.initFlutter();

  Hive.registerAdapter(ColorAdapter());
  Hive.registerAdapter(DurationAdapter());

  Hive.registerAdapter(ClasseVivaBasicProfileAdapter());
  Hive.registerAdapter(ClasseVivaProfileAdapter());
  Hive.registerAdapter(ClasseVivaProfileAvatarAdapter());
  Hive.registerAdapter(ClasseVivaCalendarAdapter());
  Hive.registerAdapter(ClasseVivaCalendarLessonAdapter());
  Hive.registerAdapter(ClasseVivaGradeAdapter());
  Hive.registerAdapter(ClasseVivaAgendaItemAdapter());
  Hive.registerAdapter(ClasseVivaGradesPeriodAdapter());
  Hive.registerAdapter(ClasseVivaAbsenceAdapter());
  Hive.registerAdapter(ClasseVivaAbsenceTypeAdapter());
  Hive.registerAdapter(ClasseVivaAbsenceStatusAdapter());

  await Hive.openBox("preferences");

  await CacheManager.initialize();

  Widget home;

  if (AuthenticationManager.isAuthenticationEnabled && !await AuthenticationManager.authenticate())
    home = SignIn();

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
      home: Builder(
        builder: (context) {
          final QuickActions quickActions = QuickActions();

          quickActions.initialize((shortcutType) {
            final ClasseViva _session = ClasseViva(ClasseViva.getCurrentSession());

            switch (shortcutType)
            {
              case "action_web":
                Get.to(ClasseVivaWebview(
                  session: _session,
                  title: "ClasseViva Web",
                  url: Uri.parse(ClasseVivaEndpoints(_session.getShortYear()).baseUrl),
                ));
                break;
            }
          });

          quickActions.setShortcutItems([
            const ShortcutItem(type: "action_web", localizedTitle: "ClasseViva Web", icon: "ic_launcher"),
          ]);

          return this.home ?? (ClasseViva.isSignedIn() ? Home() : SignIn());
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
