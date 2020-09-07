import 'package:classeviva_lite/miscellaneous/theme_manager.dart';
import 'package:flutter/material.dart';

class Spinner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(ThemeManager.isLightTheme(context)
          ? Theme.of(context).primaryColor
          : Theme.of(context).accentColor),
      ),
    );
  }
}