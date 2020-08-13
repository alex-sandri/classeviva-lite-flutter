import 'package:classeviva_lite/classeviva.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Absences extends StatefulWidget {
  @override
  _AbsencesState createState() => _AbsencesState();
}

class _AbsencesState extends State<Absences> {
  ClasseViva _session;

  List<ClasseVivaAbsence> _absences;

  Future<void> _handleRefresh() async {
    final List<ClasseVivaAbsence> absences = await _session.getAbsences();

    absences.sort((a, b) {
      // Most recent first
      return b.from.compareTo(a.from);
    });

    if (mounted)
      setState(() {
        _absences = absences;
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
            'Assenze / Ritardi'
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
                  color: Theme.of(context).primaryColor,
                  child: _absences == null
                  ? Spinner()
                  : ListView.separated(
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: _absences.length + 1,
                      itemBuilder: (context, index) {
                        if (_absences.isEmpty)
                          return SelectableText(
                            "Non sono presenti assenze o ritardi",
                            textAlign: TextAlign.center,
                          );

                        if (index == _absences.length) return Container();

                        final ClasseVivaAbsence absence = _absences[index];

                        String type;

                        switch (absence.type)
                        {
                          case ClasseVivaAbsenceType.Absence: type = "Assenza"; break;
                          case ClasseVivaAbsenceType.Late: type = "Ritardo"; break;
                          case ClasseVivaAbsenceType.ShortDelay: type = "Ritardo Breve"; break;
                          case ClasseVivaAbsenceType.EarlyExit: type = "Uscita Anticipata"; break;
                        }

                        String status;

                        switch (absence.status)
                        {
                          case ClasseVivaAbsenceStatus.Justified: status = "Giustificata"; break;
                          case ClasseVivaAbsenceStatus.NotJustified: status = "Non Giustificata"; break;
                        }

                        return ListTile(
                          title: SelectableText(
                            type,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
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
                              SelectableText(
                                status,
                              ),
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