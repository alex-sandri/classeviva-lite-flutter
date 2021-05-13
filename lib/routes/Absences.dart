import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaAbsence.dart';
import 'package:classeviva_lite/routes/AbsencesStats.dart';
import 'package:classeviva_lite/widgets/ClasseVivaRefreshableView.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Absences extends StatelessWidget {
  static String getTypeString(ClasseVivaAbsenceType type) {
    String typeString;

    switch (type)
    {
      case ClasseVivaAbsenceType.Absence: typeString = "Assenza"; break;
      case ClasseVivaAbsenceType.Late: typeString = "Ritardo"; break;
      case ClasseVivaAbsenceType.ShortDelay: typeString = "Ritardo Breve"; break;
      case ClasseVivaAbsenceType.EarlyExit: typeString = "Uscita Anticipata"; break;
    }

    return typeString;
  }

  static String getStatusString(ClasseVivaAbsenceStatus status) {
    String statusString;

    switch (status)
    {
      case ClasseVivaAbsenceStatus.Justified: statusString = "Giustificata"; break;
      case ClasseVivaAbsenceStatus.NotJustified: statusString = "Non Giustificata"; break;
    }

    return statusString;
  }

  @override
  Widget build(BuildContext context) {
    return ClasseVivaRefreshableView<List<ClasseVivaAbsence>>(
      title: "Assenze / Ritardi",
      actions: [
        IconButton(
          icon: Icon(Icons.show_chart),
          tooltip: "Infografica",
          onPressed: () => Get.to(AbsencesStats()),
        ),
      ],
      stream: () => ClasseViva.current.getAbsences(),
      builder: (absences) {
        return ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: absences.length,
          itemBuilder: (context, index) {
            final ClasseVivaAbsence absence = absences[index];

            return ListTile(
              title: SelectableText(Absences.getTypeString(absence.type)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 5,),
                  SelectableText(
                    (absence.from == absence.to || absence.from == absence.to.subtract(Duration(hours: 23, minutes: 59, seconds: 59)))
                      ? DateFormat.yMMMMd().format(absence.from)
                      : "${DateFormat.yMMMMd().format(absence.from)} - ${DateFormat.yMMMMd().format(absence.to)}",
                  ),
                  SizedBox(height: 5,),
                  SelectableText(Absences.getStatusString(absence.status)),
                  SizedBox(height: 5,),

                  if (absence.description.isNotEmpty)
                    SelectableText(
                      absence.description,
                    ),
                ],
              )
            );
          },
        );
      },
      isResultEmpty: (result) => result.isEmpty,
      emptyResultMessage: "Non sono presenti assenze o ritardi",
    );
  }
}