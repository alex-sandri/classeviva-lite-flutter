import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaFinalGrade.dart';
import 'package:classeviva_lite/widgets/classeviva_webview.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FinalGrades extends StatefulWidget {
  @override
  _FinalGradesState createState() => _FinalGradesState();
}

class _FinalGradesState extends State<FinalGrades> {
  final ClasseViva _session = ClasseViva.current;

  List<ClasseVivaFinalGrade> _finalGrades;

  Future<void> _handleRefresh() async {
    await for (final List<ClasseVivaFinalGrade> finalGrades in _session.getFinalGrades())
    {
      if (finalGrades == null) continue;

      if (mounted)
        setState(() {
          _finalGrades = finalGrades;
        });
    }
  }

  @override
  void initState() {
    super.initState();

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
                                title: item.type,
                                url: Uri.parse(item.url),
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