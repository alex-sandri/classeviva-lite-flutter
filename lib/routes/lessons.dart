import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/miscellaneous/theme_manager.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Lessons extends StatefulWidget {
  @override
  _LessonsState createState() => _LessonsState();
}

class _LessonsState extends State<Lessons> {
  final ClasseViva _session = ClasseViva(ClasseViva.getCurrentSession());

  List<ClasseVivaSubject> _subjects;

  Future<void> _handleRefresh() async {
    final List<ClasseVivaSubject> subjects = await _session.getSubjects();

    if (mounted)
      setState(() {
        _subjects = subjects;
      });
  }

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
            'Lezioni'
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
                  child: _subjects == null
                  ? Spinner()
                  : ListView.separated(
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: _subjects.length + 1,
                      itemBuilder: (context, index) {
                        if (_subjects.isEmpty)
                          return SelectableText(
                            "Non sono presenti lezioni",
                            textAlign: TextAlign.center,
                          );

                        if (index == _subjects.length) return Container();

                        final ClasseVivaSubject subject = _subjects[index];

                        return Card(
                          child: ExpansionTile(
                            title: Text(
                              subject.name,
                              style: TextStyle(
                                color: ThemeManager.isLightTheme(context)
                                  ? Colors.black
                                  : Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            children: [
                              FutureBuilder(
                                future: _session.getLessons(subject),
                                builder: (context, AsyncSnapshot<List<ClasseVivaLesson>> lessons) {
                                  if (!lessons.hasData)
                                    return Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Spinner(),
                                    );

                                  return Column(
                                    children: lessons.data.map((lesson) {
                                      return ListTile(
                                        title: SelectableText(
                                          lesson.description,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        subtitle: SelectableText(
                                          DateFormat.yMMMMd().format(lesson.date),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              )
                            ],
                          ),
                        );
                      },
                    ),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}