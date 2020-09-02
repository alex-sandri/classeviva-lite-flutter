import 'package:classeviva_lite/classeviva.dart';
import 'package:classeviva_lite/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ClasseVivaWebview extends StatefulWidget {
  final ClasseViva session;

  final String title;
  final Uri url;

  ClasseVivaWebview({
    @required this.session,
    @required this.title,
    @required this.url,
  });

  @override
  _ClasseVivaWebviewState createState() => _ClasseVivaWebviewState();
}

class _ClasseVivaWebviewState extends State<ClasseVivaWebview> {
  int _loadProgress = 0;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
          ),
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrl: widget.url.toString(),
              initialHeaders: widget.session.getSessionCookieHeader(),
              onProgressChanged: (controller, progress) {
                setState(() {
                  _loadProgress = progress;
                });
              },
            ),

            if (_loadProgress < 100)
              LinearProgressIndicator(
                value: _loadProgress.toDouble(),
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(ThemeManager.isLightTheme(context)
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).accentColor),
              ),
          ],
        ),
      ),
    );
  }
}