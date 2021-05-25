import 'package:classeviva_lite/config/Config.dart';
import 'package:flutter/material.dart';

class ThemeConfig {
  static ThemeData dark(BuildContext context) {
    return ThemeData.dark().copyWith(
      accentColor: Config.SECONDARY_COLOR,
      appBarTheme: AppBarTheme(
        brightness: Brightness.dark,
        color: Config.PRIMARY_COLOR,
        elevation: 0,
      ),
      cardTheme: Theme.of(context).cardTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      colorScheme: ColorScheme.dark(
        primary: Config.SECONDARY_COLOR,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(
          color: Config.SECONDARY_COLOR,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: Config.SECONDARY_COLOR,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: Config.SECONDARY_COLOR,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(
            color: Config.SECONDARY_COLOR,
          ),
        ),
      ),
      tabBarTheme: TabBarTheme(
        indicator: UnderlineTabIndicator(),
      ),
      textTheme: Theme.of(context).textTheme
        .copyWith(
          headline6: Theme.of(context).textTheme.headline6.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        )
        .apply(
          bodyColor: Config.SECONDARY_COLOR,
          displayColor: Config.SECONDARY_COLOR,
        ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Config.SECONDARY_COLOR),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled))
            {
              return Colors.grey.shade800;
            }

            return Colors.grey.shade600;
          }),
          padding: MaterialStateProperty.all(EdgeInsets.all(15)),
          textStyle: MaterialStateProperty.all(
            TextStyle(
              fontSize: 20,
            ),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
    );
  }
}
