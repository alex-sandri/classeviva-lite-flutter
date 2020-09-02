import 'package:classeviva_lite/classeviva.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class FinalGrades extends StatefulWidget {
  @override
  _FinalGradesState createState() => _FinalGradesState();
}

class _FinalGradesState extends State<FinalGrades> {
  ClasseViva _session;

  List<ClasseVivaFinalGrade> _finalGrades;

  Future<void> _handleRefresh() async {
    final List<ClasseVivaFinalGrade> finalGrades = await _session.getFinalGrades();

    if (mounted)
      setState(() {
        _finalGrades = finalGrades;
      });
  }

  @override
  void initState() {
    super.initState();

    ClasseViva.getCurrentSession().then((session) {
      _session = ClasseViva(session);

      _handleRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Scrutini"
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: _session == null
            ? Spinner()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _handleRefresh,
                      backgroundColor: Theme.of(context).appBarTheme.color,
                      child: _finalGrades == null
                        ? Spinner()
                        : ListView.builder(
                            itemCount: _finalGrades.isNotEmpty
                              ? _finalGrades.length
                              : 1,
                            itemBuilder: (context, index) {
                              if (_finalGrades.isEmpty)
                              {
                                return SelectableText(
                                  "Non sono presenti documenti",
                                  textAlign: TextAlign.center,
                                );
                              }

                              final ClasseVivaFinalGrade item = _finalGrades[index];

                              return ListTile(
                                title: Text(
                                  item.type,
                                ),
                                onTap: () async {
                                  await CookieManager.instance().deleteAllCookies();

                                  await CookieManager.instance().setCookie(
                                    url: ClasseVivaEndpoints(_session.getShortYear()).baseUrl,
                                    name: _session.getSessionCookieHeader()["Cookie"].split("=").first,
                                    value: _session.getSessionCookieHeader()["Cookie"].split("=").last,
                                  );

                                  Get.to(FinalGradeWebview(item: item));
                                },
                              );
                            },
                          ),
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}

class FinalGradeWebview extends StatelessWidget {
  final ClasseVivaFinalGrade item;

  FinalGradeWebview({
    @required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Esito",
          ),
        ),
        body: InAppWebView(
          initialUrl: item.url.toString(),
        ),
      ),
    );
  }
}