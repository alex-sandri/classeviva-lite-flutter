import 'package:classeviva_lite/classeviva.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';

class FinalGrades extends StatefulWidget {
  @override
  _FinalGradesState createState() => _FinalGradesState();
}

class _FinalGradesState extends State<FinalGrades> {
  ClasseViva _session;

  List<String> _finalGrades;

  Future<void> _handleRefresh() async {
    final List<String> finalGrades = await _session.getFinalGrades();

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
                            itemCount: _finalGrades.length + 1,
                            itemBuilder: (context, index) {
                              if (_finalGrades.isEmpty)
                              {
                                return SelectableText(
                                  "Non sono presenti documenti",
                                  textAlign: TextAlign.center,
                                );
                              }

                              return Card();
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