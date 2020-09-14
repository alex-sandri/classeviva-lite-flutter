import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaAbsence.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Absences extends StatefulWidget {
  @override
  _AbsencesState createState() => _AbsencesState();

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
}

class _AbsencesState extends State<Absences> {
  final ClasseViva _session = ClasseViva(ClasseViva.getCurrentSession());

  List<ClasseVivaAbsence> _absences;

  Future<void> _fetch() async {
    await for (final List<ClasseVivaAbsence> absences in _session.getAbsences())
    {
      if (absences == null) continue;

      if (mounted)
        setState(() {
          _absences = absences;
        });
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _absences = null;
    });

    await _fetch();
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
            'Assenze / Ritardi'
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
                  child: _absences == null
                  ? Spinner()
                  : ListView.separated(
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: _absences.isNotEmpty
                        ? _absences.length
                        : 1,
                      itemBuilder: (context, index) {
                        if (_absences.isEmpty)
                          return SelectableText(
                            "Non sono presenti assenze o ritardi",
                            textAlign: TextAlign.center,
                          );

                        final ClasseVivaAbsence absence = _absences[index];

                        return ListTile(
                          title: SelectableText(Absences.getTypeString(absence.type)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 5,),
                              SelectableText(
                                absence.from == absence.to
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