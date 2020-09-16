import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaAgendaItem.dart';
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
  final ClasseViva _session = ClasseViva(ClasseViva.getCurrentSession());

  DateTime _start;

  DateTime _end;

  List<ClasseVivaAgendaItem> _items;

  Future<void> _handleRefresh() async {
    await for (final List<ClasseVivaAgendaItem> items in _session.getAgenda(_start, _end))
    {
      if (items == null) continue;

      if (mounted)
        setState(() {
          _items = items;
        });
    }
  }

  void initState() {
    super.initState();

    _start = _session.yearBeginsAt;

    _end = _session.yearEndsAt;

    _handleRefresh();
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
              tooltip: "Cambia periodo",
              onPressed: () async {
                final DateTimeRange selectedDateRange = await showDateRangePicker(
                  context: context,
                  initialDateRange: DateTimeRange(start: _start, end: _end),
                  firstDate: _session.yearBeginsAt,
                  lastDate: _session.yearEndsAt,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  backgroundColor: Theme.of(context).appBarTheme.color,
                  child: _items == null
                  ? Spinner()
                  : ListView.separated(
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: _items.isNotEmpty
                        ? _items.length
                        : 1,
                      itemBuilder: (context, index) {
                        if (_items.isEmpty)
                          return SelectableText(
                            "Non sono presenti elementi in agenda nel periodo selezionato",
                            textAlign: TextAlign.center,
                          );

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

  final bool showDay;

  AgendaItemTile(this._item, { this.showDay = true, });

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat.jm();

    if (showDay) dateFormat = dateFormat.add_yMMMMd();

    return ListTile(
      title: SelectableText(
        _item.autore_desc,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 5,),
          SelectableText(
            "(${dateFormat.format(_item.start)} - ${dateFormat.format(_item.end)})",
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