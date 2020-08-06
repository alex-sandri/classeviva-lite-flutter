import 'package:classeviva_lite/classeviva.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Agenda extends StatefulWidget {
  @override
  _AgendaState createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  ClasseViva _session;

  // Today at 00:00:00
  DateTime _start = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  // Today at 23:59:59
  DateTime _end = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59);

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
            'Agenda & Compiti'
          ),
          elevation: 0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () async {
                // TODO: Allow period choice
                final DateTime selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1970),
                  lastDate: DateTime(2099),
                );

                _start = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
                _end = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

                _handleRefresh();
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
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
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
                                SelectableText(
                                  item.nota_2,
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                  ),
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