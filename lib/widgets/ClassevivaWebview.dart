import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ClasseVivaWebview extends StatefulWidget {
  final String title;
  final Uri url;

  ClasseVivaWebview({
    @required this.title,
    @required this.url,
  });

  @override
  _ClasseVivaWebviewState createState() => _ClasseVivaWebviewState();
}

class _ClasseVivaWebviewState extends State<ClasseVivaWebview> {
  int _loadProgress = 0;

  @override
  void initState() {
    super.initState();

    CookieManager.instance().deleteAllCookies();

    final ClasseViva session = ClasseViva.current;

    CookieManager.instance().setCookie(
      url: Uri.parse(ClasseVivaEndpoints(session.getShortYear()).baseUrl),
      name: session.getSessionCookieHeader()["Cookie"].split("=").first,
      value: session.getSessionCookieHeader()["Cookie"].split("=").last,
    );
  }

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
              initialUrlRequest: URLRequest(url: widget.url),
              onProgressChanged: (controller, progress) {
                setState(() {
                  _loadProgress = progress;
                });
              },
            ),

            if (_loadProgress < 100)
              LinearProgressIndicator(
                value: _loadProgress.toDouble(),
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(ClasseViva.PRIMARY_LIGHT),
              ),
          ],
        ),
      ),
    );
  }
}