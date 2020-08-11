import 'package:classeviva_lite/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Lessons extends StatefulWidget {
  @override
  _LessonsState createState() => _LessonsState();
}

class _LessonsState extends State<Lessons> {
  ClasseViva _session;

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

    ClasseViva.getCurrentSession().then((session) {
      _session = ClasseViva(
        session: session,
        context: context
      );

      _handleRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Lezioni'
          ),
          elevation: 0,
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
            color: Theme.of(context).primaryColor,
            width: double.infinity,
            child: _session == null
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
                  ),
                )
              : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: Theme.of(context).primaryColor,
                    child: _subjects == null
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
                        ),
                      )
                    : ListView.separated(
                        separatorBuilder: (context, index) => Divider(
                          color: Theme.of(context).accentColor,
                        ),
                        itemCount: _subjects.length + 1,
                        itemBuilder: (context, index) {
                          if (_subjects.isEmpty)
                            return SelectableText(
                              "Non sono presenti lezioni",
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                              ),
                              textAlign: TextAlign.center,
                            );

                          if (index == _subjects.length) return Container();

                          final ClasseVivaSubject subject = _subjects[index];

                          return Card(
                            color: Colors.transparent,
                            child: ExpansionTile(
                              title: Text(
                                subject.name,
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
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
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
                                          ),
                                        ),
                                      );

                                    return Column(
                                      children: lessons.data.map((lesson) {
                                        return ListTile(
                                          title: SelectableText(
                                            lesson.description,
                                            style: TextStyle(
                                              color: Theme.of(context).accentColor,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          subtitle: SelectableText(
                                            DateFormat.yMMMMd().format(lesson.date),
                                            style: TextStyle(
                                              color: Theme.of(context).accentColor,
                                            ),
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
      ),
    );
  }
}