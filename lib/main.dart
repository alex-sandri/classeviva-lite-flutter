import 'package:classeviva_lite/adapters/ColorAdapter.dart';
import 'package:classeviva_lite/adapters/DurationAdapter.dart';
import 'package:classeviva_lite/miscellaneous/PreferencesManager.dart';
import 'package:classeviva_lite/miscellaneous/authentication_manager.dart';
import 'package:classeviva_lite/miscellaneous/cache_manager.dart';
import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaAbsence.dart';
import 'package:classeviva_lite/models/ClasseVivaAbsenceMonth.dart';
import 'package:classeviva_lite/models/ClasseVivaAgendaItem.dart';
import 'package:classeviva_lite/models/ClasseVivaAttachment.dart';
import 'package:classeviva_lite/models/ClasseVivaBasicProfile.dart';
import 'package:classeviva_lite/models/ClasseVivaBook.dart';
import 'package:classeviva_lite/models/ClasseVivaBulletinBoardItem.dart';
import 'package:classeviva_lite/models/ClasseVivaBulletinBoardItemDetails.dart';
import 'package:classeviva_lite/models/ClasseVivaCalendar.dart';
import 'package:classeviva_lite/models/ClasseVivaCalendarLesson.dart';
import 'package:classeviva_lite/models/ClasseVivaDemerit.dart';
import 'package:classeviva_lite/models/ClasseVivaFinalGrade.dart';
import 'package:classeviva_lite/models/ClasseVivaGrade.dart';
import 'package:classeviva_lite/models/ClasseVivaGradesPeriod.dart';
import 'package:classeviva_lite/models/ClasseVivaLesson.dart';
import 'package:classeviva_lite/models/ClasseVivaMessage.dart';
import 'package:classeviva_lite/models/ClasseVivaProfile.dart';
import 'package:classeviva_lite/models/ClasseVivaProfileAvatar.dart';
import 'package:classeviva_lite/models/ClasseVivaSubject.dart';
import 'package:classeviva_lite/routes/Home.dart';
import 'package:classeviva_lite/routes/SignIn.dart';
import 'package:classeviva_lite/miscellaneous/theme_manager.dart';
import 'package:classeviva_lite/widgets/ClassevivaWebview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:workmanager/workmanager.dart' as wm;

Future<void> checkForNewMessages() async {
  await for (final List<ClasseVivaMessage> messages in ClasseViva.current.getMessages())
  {
    if (messages == null) continue;

    for (final ClasseVivaMessage message in messages)
    {
      if (message.isRead) continue;

      await FlutterLocalNotificationsPlugin().show(0, message.subject, message.content, NotificationDetails(
        android: AndroidNotificationDetails(
          "0",
          "Messaggi",
          "Messaggi",
        ),
        iOS: IOSNotificationDetails(),
      ));

      await message.markAsRead();
    }
  }
}

void callbackDispatcher() async {
  wm.Workmanager().executeTask((task, inputData) async {
    await checkForNewMessages();

    return true;
  });
}

void main() async {
  await FlutterDownloader.initialize(debug: false);

  await Hive.initFlutter();

  Hive.registerAdapter(ColorAdapter());
  Hive.registerAdapter(DurationAdapter());

  /* 0 */ Hive.registerAdapter(ClasseVivaBasicProfileAdapter());
  /* 1 */ Hive.registerAdapter(ClasseVivaProfileAdapter());
  /* 2 */ Hive.registerAdapter(ClasseVivaProfileAvatarAdapter());
  /* 3 */ Hive.registerAdapter(ClasseVivaCalendarAdapter());
  /* 4 */ Hive.registerAdapter(ClasseVivaGradeAdapter());
  /* 5 */ Hive.registerAdapter(ClasseVivaAgendaItemAdapter());
  /* 6 */ Hive.registerAdapter(ClasseVivaCalendarLessonAdapter());
  /* 7 */ Hive.registerAdapter(ClasseVivaGradesPeriodAdapter());
  /* 8 */ Hive.registerAdapter(ClasseVivaAbsenceAdapter());
  /* 9 */ Hive.registerAdapter(ClasseVivaAbsenceTypeAdapter());
  /* 10 */ Hive.registerAdapter(ClasseVivaAbsenceStatusAdapter());
  /* 11 */ Hive.registerAdapter(ClasseVivaSubjectAdapter());
  /* 12 */ Hive.registerAdapter(ClasseVivaLessonAdapter());
  /* 13 */ Hive.registerAdapter(ClasseVivaDemeritAdapter());
  /* 14 */ Hive.registerAdapter(ClasseVivaBookAdapter());
  /* 15 */ Hive.registerAdapter(ClasseVivaAttachmentAdapter());
  /* 16 */ Hive.registerAdapter(ClasseVivaAttachmentTypeAdapter());
  /* 17 */ Hive.registerAdapter(ClasseVivaBulletinBoardItemAdapter());
  /* 18 */ Hive.registerAdapter(ClasseVivaBulletinBoardItemDetailsAdapter());
  /* 19 */ Hive.registerAdapter(ClasseVivaBulletinBoardItemDetailsAttachmentAdapter());
  /* 20 */ Hive.registerAdapter(ClasseVivaFinalGradeAdapter());
  /* 21 */ Hive.registerAdapter(ClasseVivaAbsenceMonthAdapter());
  /* 22 */ Hive.registerAdapter(ClasseVivaMessageAdapter());

  await PreferencesManager.initialize();

  await CacheManager.initialize();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings("app_icon"),
    iOS: IOSInitializationSettings(),
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (payload) => null,
  );

  wm.Workmanager().initialize(callbackDispatcher);

  wm.Workmanager().registerPeriodicTask(
    "fetchMessages",
    "fetchMessages",
    frequency: Duration(minutes: 15),
    constraints: wm.Constraints(
      networkType: wm.NetworkType.connected,
    ),
  );

  checkForNewMessages();

  Widget home;

  if (AuthenticationManager.isAuthenticationEnabled && !await AuthenticationManager.authenticate())
    home = SignIn();

  runApp(MyApp(home: home));
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
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.white),
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.disabled))
              {
                return Colors.grey.withAlpha(150);
              }

              return ClasseViva.PRIMARY_LIGHT;
            }),
            padding: MaterialStateProperty.all(EdgeInsets.all(15)),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
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
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.black),
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.disabled))
              {
                return Colors.grey.shade700;
              }

              return Colors.white;
            }),
            padding: MaterialStateProperty.all(EdgeInsets.all(15)),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: ThemeManager.themeMode,
      home: Builder(
        builder: (context) {
          Intl.defaultLocale = Localizations.localeOf(context).toLanguageTag();

          final QuickActions quickActions = QuickActions();

          quickActions.initialize((shortcutType) {
            switch (shortcutType)
            {
              case "action_web":
                Get.to(ClasseVivaWebview(
                  title: "ClasseViva Web",
                  url: Uri.parse(ClasseVivaEndpoints.current.baseUrl),
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
