import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaLesson.dart';
import 'package:classeviva_lite/models/ClasseVivaSubject.dart';
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
    await for (final List<ClasseVivaSubject> subjects in _session.getSubjects())
    {
      if (subjects == null) continue;

      if (mounted)
        setState(() {
          _subjects = subjects;
        });
    }
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
                  : ListView.builder(
                      itemCount: _subjects.isNotEmpty
                        ? _subjects.length
                        : 1,
                      itemBuilder: (context, index) {
                        if (_subjects.isEmpty)
                          return SelectableText(
                            "Non sono presenti lezioni",
                            textAlign: TextAlign.center,
                          );

                        final ClasseVivaSubject subject = _subjects[index];

                        return ExpansionTile(
                          title: Text(subject.name),
                          children: [
                            LessonsListView(subject: subject),
                          ],
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

class LessonsListView extends StatelessWidget {
  final ClasseVivaSubject subject;

  LessonsListView({
    @required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ClasseVivaLesson>>(
      stream: ClasseViva(ClasseViva.getCurrentSession()).getLessons(subject),
      builder: (context, lessons) {
        if (!lessons.hasData)
          return Padding(
            padding: EdgeInsets.all(8),
            child: Spinner(),
          );

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: lessons.data.length,
          itemBuilder: (context, index) {
            final ClasseVivaLesson lesson = lessons.data[index];

            return ListTile(
              title: SelectableText("${DateFormat.yMMMMd().format(lesson.date)} - ${lesson.teacher}"),
              subtitle: SelectableText(lesson.description),
            );
          },
        );
      },
    );
  }
}