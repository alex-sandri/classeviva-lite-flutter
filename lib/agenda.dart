import 'package:classeviva_lite/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Agenda extends StatefulWidget {
  @override
  _AgendaState createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  ClasseViva _session;

  DateTime _start;

  DateTime _end;

  List<ClasseVivaAgendaItem> _items;

  Future<void> _handleRefresh() async {
    final List<ClasseVivaAgendaItem> items = await _session.getAgenda(_start, _end);

    items.sort((a, b) {
      // Most recent first
      return b.start.compareTo(a.start);
    });

    if (mounted)
      setState(() {
        _items = items;
      });
  }

  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((preferences) async {
      _session = ClasseViva(
        session: await ClasseViva.getCurrentSession(),
        context: context
      );

      _start = _session.yearBeginsAt;

      _end = _session.yearEndsAt;

      _handleRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Agenda & Compiti'
          ),
          elevation: 0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () async {
                final DateTimeRange selectedDate = await showDateRangePicker(
                  context: context,
                  initialDateRange: DateTimeRange(start: DateTime.now(), end: DateTime.now()),
                  firstDate: DateTime(1970),
                  lastDate: DateTime(2099),
                );

                if (selectedDate != null)
                {
                  _start = DateTime(selectedDate.start.year, selectedDate.start.month, selectedDate.start.day);
                  _end = DateTime(selectedDate.end.year, selectedDate.end.month, selectedDate.end.day, 23, 59, 59);

                  print({_start, _end});

                  _handleRefresh();
                }
              },
            ),
          ],
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
                    child: _items == null
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
                        ),
                      )
                    : ListView.separated(
                        separatorBuilder: (context, index) => Divider(
                          color: Theme.of(context).accentColor,
                        ),
                        itemCount: _items.length + 1,
                        itemBuilder: (context, index) {
                          if (_items.isEmpty)
                            return SelectableText(
                              "Non sono presenti elementi in agenda nel periodo selezionato",
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                              ),
                              textAlign: TextAlign.center,
                            );

                          if (index == _items.length) return Container();

                          final ClasseVivaAgendaItem item = _items[index];

                          return ListTile(
                            title: SelectableText(
                              item.autore_desc,
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 5,),
                                SelectableText(
                                  "(${DateFormat.yMMMMd().add_jm().format(item.start)} - ${DateFormat.yMMMMd().add_jm().format(item.end)})",
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                                SizedBox(height: 5,),
                                SelectableLinkify(
                                  text: item.nota_2,
                                  options: LinkifyOptions(humanize: false),
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                  ),
                                  onOpen: (link) async {
                                    if (await canLaunch(link.url)) await launch(link.url);
                                    else
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text("Errore"),
                                            content: Text("Impossibile aprire il link"),
                                          );
                                        },
                                      );
                                  },
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
      ),
    );
  }
}