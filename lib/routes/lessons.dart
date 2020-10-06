import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaLesson.dart';
import 'package:classeviva_lite/models/ClasseVivaSubject.dart';
import 'package:classeviva_lite/widgets/ClasseVivaRefreshableView.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Lessons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClasseVivaRefreshableView<List<ClasseVivaSubject>>(
      title: "Lezioni",
      stream: () => ClasseViva.current.getSubjects(),
      builder: (subjects) {
        return ListView.builder(
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final ClasseVivaSubject subject = subjects[index];

            return ExpansionTile(
              title: Text(subject.name),
              children: [ LessonsListView(subject: subject) ],
            );
          },
        );
      },
      isResultEmpty: (result) => result.isEmpty,
      emptyResultMessage: "Non sono presenti lezioni",
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
      stream: ClasseViva.current.getLessons(subject),
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