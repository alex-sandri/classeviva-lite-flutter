import 'package:classeviva_lite/classeviva.dart';
import 'package:classeviva_lite/widgets/classeviva_webview.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';
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

    _session =  ClasseViva(ClasseViva.getCurrentSession());

    _handleRefresh();
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
          child: Column(
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
                            onTap: () {
                              Get.to(ClasseVivaWebview(
                                session: _session,
                                title: item.type,
                                url: item.url,
                              ));
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