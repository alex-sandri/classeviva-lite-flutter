import 'package:classeviva_lite/miscellaneous/ClasseVivaSearchDelegate.dart';
import 'package:classeviva_lite/miscellaneous/classeviva.dart';
import 'package:classeviva_lite/models/ClasseVivaAgendaItem.dart';
import 'package:classeviva_lite/routes/Calendar.dart';
import 'package:classeviva_lite/widgets/ClasseVivaRefreshableView.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class Agenda extends StatefulWidget {
  @override
  _AgendaState createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  final ClasseViva _session = ClasseViva.current;

  DateTime _start;

  DateTime _end;

  void initState() {
    super.initState();

    _start = _session.yearBeginsAt;

    _end = _session.yearEndsAt;
  }

  @override
  Widget build(BuildContext context) {
    return ClasseVivaRefreshableView<List<ClasseVivaAgendaItem>>(
      title: "Agenda & Compiti",
      actions: <Widget>[
        Builder(
          builder: (context) {
            return IconButton(
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

                  ClasseVivaRefreshableViewRefreshNotification().dispatch(context);
                }
              },
            );
          }
        ),
        IconButton(
          icon: Icon(Icons.search),
          tooltip: "Cerca",
          onPressed: () => showSearch(
            context: context,
            delegate: ClasseVivaSearchDelegate<ClasseVivaAgendaItem>(
              stream: (query) async* {
                final ClasseViva session = ClasseViva.current;

                yield* session.getAgenda(session.yearBeginsAt, session.yearEndsAt, query: query);
              },
              rawBuilder: (items) => _AgendaListView(items),
            ),
          ),
        ),
      ],
      stream: () => _session.getAgenda(_start, _end),
      builder: (items) => _AgendaListView(items),
      isResultEmpty: (result) => result.isEmpty,
      emptyResultMessage: "Non sono presenti elementi in agenda nel periodo selezionato",
    );
  }
}

class _AgendaListView extends StatelessWidget {
  final List<ClasseVivaAgendaItem> items;

  _AgendaListView(this.items);

  @override
  Widget build(BuildContext context) {
    final Map<DateTime, List<ClasseVivaAgendaItem>> itemsGroupedByDay = groupBy(items, (item) => DateTime(
      item.start.year,
      item.start.month,
      item.start.day,
    ));

    return ListView.builder(
      itemCount: itemsGroupedByDay.length,
      itemBuilder: (context, index) {
        final MapEntry<DateTime, List<ClasseVivaAgendaItem>> itemsForDay = itemsGroupedByDay.entries.elementAt(index);

        itemsForDay.value.sort((a, b) {
          // Earliest first
          return a.start.compareTo(b.start);
        });

        return StickyHeader(
          header: Material(
            color: ClasseViva.PRIMARY_LIGHT,
            child: InkWell(
              onTap: () => Get.to(Calendar(day: itemsForDay.key)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                child: Text(
                  DateFormat.yMMMMd().format(itemsForDay.key),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                alignment: Alignment.center,
              ),
            ),
          ),
          content: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: itemsForDay.value.length,
            itemBuilder: (context, index) => AgendaItemTile(itemsForDay.value[index]),
          ),
        );
      },
    );
  }
}

class AgendaItemTile extends StatelessWidget {
  final ClasseVivaAgendaItem _item;

  AgendaItemTile(this._item);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: SelectableText(_item.authorDescription),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 5),
          SelectableText("(${DateFormat.jm().format(_item.start)} - ${DateFormat.jm().format(_item.end)})"),
          SizedBox(height: 5),
          SelectableLinkify(
            text: _item.content,
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
      ),
      trailing: IconButton(
        icon: Icon(Icons.info),
        tooltip: "Informazioni",
        onPressed: () => showDialog(
          context: context,
          child: Dialog(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: SelectableText("Data inserimento"),
                  subtitle: SelectableText(DateFormat.yMMMMd().add_jm().format(_item.addedDate)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}