import 'package:classeviva_lite/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Absences extends StatefulWidget {
  @override
  _AbsencesState createState() => _AbsencesState();
}

class _AbsencesState extends State<Absences> {
  ClasseViva _session;

  List<ClasseVivaAbsence> _absences;

  Future<void> _handleRefresh() async {
    final List<ClasseVivaAbsence> absences = await _session.getAbsences();

    if (mounted)
      setState(() {
        _absences = absences;
      });
  }

  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((preferences) {
      _session = ClasseViva(
        sessionId: preferences.getString("sessionId"),
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
                    child: _absences == null
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
                        ),
                      )
                    : ListView.separated(
                        separatorBuilder: (context, index) => Divider(
                          color: Theme.of(context).accentColor,
                        ),
                        itemCount: _absences.length + 1,
                        itemBuilder: (context, index) {
                          if (_absences.isEmpty)
                            return SelectableText(
                              "Non sono presenti assenze o ritardi",
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                              ),
                              textAlign: TextAlign.center,
                            );

                          if (index == _absences.length) return Container();

                          final ClasseVivaAbsence item = _absences[index];

                          print(item);

                          return ListTile();
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