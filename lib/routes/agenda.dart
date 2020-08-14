import 'package:classeviva_lite/classeviva.dart';
import 'package:classeviva_lite/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
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
    setState(() {
      _items = null;
    });

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

    ClasseViva.getCurrentSession().then((session) {
      _session = ClasseViva(
        session: session,
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
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () async {
                final DateTimeRange selectedDateRange = await showDateRangePicker(
                  context: context,
                  initialDateRange: DateTimeRange(start: _start, end: _end),
                  firstDate: DateTime(1970),
                  lastDate: DateTime(2099),
                );

                if (selectedDateRange != null)
                {
                  _start = DateTime(selectedDateRange.start.year, selectedDateRange.start.month, selectedDateRange.start.day);
                  _end = DateTime(selectedDateRange.end.year, selectedDateRange.end.month, selectedDateRange.end.day, 23, 59, 59);

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
          child: _session == null
            ? Spinner()
            : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: Theme.of(context).primaryColor,
                  child: _items == null
                  ? Spinner()
                  : ListView.separated(
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: _items.length + 1,
                      itemBuilder: (context, index) {
                        if (_items.isEmpty)
                          return SelectableText(
                            "Non sono presenti elementi in agenda nel periodo selezionato",
                            textAlign: TextAlign.center,
                          );

                        if (index == _items.length) return Container();

                        final ClasseVivaAgendaItem item = _items[index];

                        return AgendaItemTile(item);
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

class AgendaItemTile extends StatelessWidget {
  final ClasseVivaAgendaItem _item;

  AgendaItemTile(this._item);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: SelectableText(
        _item.autore_desc,
        style: TextStyle(
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 5,),
          SelectableText(
            "(${DateFormat.yMMMMd().add_jm().format(_item.start)} - ${DateFormat.yMMMMd().add_jm().format(_item.end)})",
          ),
          SizedBox(height: 5,),
          SelectableLinkify(
            text: _item.nota_2,
            options: LinkifyOptions(humanize: false),
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
  }
}